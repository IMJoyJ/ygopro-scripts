--モーター・カイザル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。进行1只机械族·暗属性怪兽的召唤。
-- ②：以自己场上1只怪兽为对象才能发动。那只怪兽破坏。那之后，可以在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册该卡的效果①（手卡展示并召唤机械族·暗属性怪兽）与效果②（破坏场上怪兽并特召衍生物）
function s.initial_effect(c)
	-- 将卡片密码82556059（马达壳）加入该卡记载的卡片密码列表中
	aux.AddCodeList(c,82556059)
	-- ①：把手卡的这张卡给对方观看才能发动。进行1只机械族·暗属性怪兽的召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sumcost)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只怪兽为对象才能发动。那只怪兽破坏。那之后，可以在自己场上把1只「马达衍生物」（机械族·地·1星·攻/守200）攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价：确认手卡的这张卡未给对方观看（未公开状态）
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤条件：场上或手卡中可以进行通常召唤的机械族·暗属性怪兽
function s.sumfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonable(true,nil)
end
-- 效果①的发动准备：检查是否存在可召唤的机械族·暗属性怪兽，并设置召唤的操作信息
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己手卡或场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁信息，表示该效果包含召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理：让玩家选择手卡或场上1只满足条件的机械族·暗属性怪兽进行通常召唤
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手卡或场上选择1只满足条件的机械族·暗属性怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行无视每回合通常召唤次数限制的通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果②的发动准备：选择自己场上1只怪兽作为对象，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动阶段，检查自己场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送提示信息，要求选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁信息，表示该效果包含破坏选中的对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：破坏作为对象的怪兽，之后若满足条件，玩家可以选择在自己场上特殊召唤1只「马达衍生物」
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍在该效果的连锁中、是否为怪兽，并将其因效果破坏
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查玩家是否能够将1只机械族·地属性·1星·攻/守200的衍生物以攻击表示特殊召唤到自己场上
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,200,200,1,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP_ATTACK,tp,0)
		-- 询问玩家是否选择特殊召唤衍生物
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤衍生物？"
			-- 中断当前效果处理，使后续的特殊召唤处理与破坏处理不视为同时进行（造成错时点）
			Duel.BreakEffect()
			-- 在卡片数据中创建1只「马达衍生物」
			local token=Duel.CreateToken(tp,id+o)
			-- 将创建的衍生物以攻击表示特殊召唤到自己场上
			Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
