--ビック・バイパー Type－L
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己战斗阶段开始时，可以从以下效果选择1个发动。
-- ●从手卡把1只机械族怪兽特殊召唤。
-- ●从卡组把1只4星以下的机械族·光属性怪兽送去墓地。
-- ②：这张卡被破坏的场合，以自己墓地1只机械族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果的选择性效果以及②效果被破坏时特殊召唤墓地怪兽的效果
function s.initial_effect(c)
	-- ①：自己战斗阶段开始时，可以从以下效果选择1个发动。 ●从手卡把1只机械族怪兽特殊召唤。 ●从卡组把1只4星以下的机械族·光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合，以自己墓地1只机械族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 触发条件判定：当前必须是自己的回合（用于战斗阶段开始时）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 过滤条件：手卡中可以特殊召唤的机械族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：卡组中等级在4星以下、光属性且是机械族的可送墓怪兽
function s.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- 效果发动的目标检查与选择：检查特召和送墓条件，供玩家在两个选项中选择一个，并根据选择设置相应的效果分类和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的机械族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	-- 检查卡组中是否存在满足送去墓地条件的4星以下机械族·光属性怪兽
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家在可用的选项中选择需要发动的效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"送去墓地"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置当前连锁的操作信息：从手卡特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
		end
		-- 设置当前连锁的操作信息：从卡组将1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理的操作：根据玩家的发动选择，执行从手卡特召怪兽，或从卡组将符合条件的怪兽送去墓地
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 检查自己场上是否有可用的主要怪兽区
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择手卡中要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 玩家从手卡选择1只符合特殊召唤条件的机械族怪兽
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的怪兽以表侧表示特殊召唤
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择卡组中要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家从卡组中选择1只符合条件的4星以下机械族·光属性怪兽
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 过滤条件：墓地中可以特殊召唤的机械族·光属性怪兽
function s.spfilter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标检查与选择：检查自己场上的怪兽区域空间，并在墓地中选择1只符合条件的怪兽作为特召的对象
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在可以成为发动对象的机械族·光属性怪兽
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只可以特殊召唤的机械族·光属性怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：将选择的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的操作：特殊召唤作为对象的怪兽，若该怪兽原本攻击力在1200以下，则使其上升1200攻击力
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为特殊召唤对象的卡
	local tc=Duel.GetFirstTarget()
	-- 检查该卡是否仍与该连锁相关（且不受王之谷影响）
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 尝试将目标怪兽以表侧表示特殊召唤（作为多步骤特殊召唤的一部分）
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		and tc:GetBaseAttack()<=1200 then
		-- 这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤的全部后续处理步骤
	Duel.SpecialSummonComplete()
end
