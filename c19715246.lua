--サイバー・ヨルムンガンド
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组选1只「电子龙」特殊召唤或当作装备魔法卡使用给这张卡装备。这个回合，自己不是机械族怪兽不能特殊召唤。
-- ②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册特殊召唤条件、①效果（特殊召唤）和②效果（检索）
function s.initial_effect(c)
	-- 记录该卡与「电子龙」和「融合」的关联
	aux.AddCodeList(c,70095154,24094653)
	-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	-- ①：对方场上有怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，从卡组选1只「电子龙」特殊召唤或当作装备魔法卡使用给这张卡装备。这个回合，自己不是机械族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：让自己场上1张「电子龙」回到手卡才能发动。从自己的卡组·墓地把1张「融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 设置该卡不能通常召唤，只能通过效果特殊召唤
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- ①效果的发动条件：对方场上有怪兽存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 筛选卡组中可特殊召唤或装备的「电子龙」
function s.eqfilter(c,e,tp,chk)
	return c:IsCode(70095154)
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) and
			-- 若选择特殊召唤，则判断是否有怪兽区域
			(not chk and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 若选择特殊召唤，则判断是否能进行2次特殊召唤且有怪兽区域
			or chk and Duel.IsPlayerCanSpecialSummonCount(tp,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1)
		-- 若选择装备，则判断是否有装备区域且该卡未被禁止
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) and not c:IsForbidden())
end
-- ①效果的发动条件判断
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否有怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断卡组中是否存在满足条件的「电子龙」
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK,0,1,nil,e,tp,true) end
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 从卡组中选择1只满足条件的「电子龙」
		local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,false)
		local tc=g:GetFirst()
		if tc then
			-- 判断是否能特殊召唤该「电子龙」
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 判断是否能装备该「电子龙」
			local b2=Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:CheckUniqueOnField(tp) and not tc:IsForbidden()
			local op=0
			if b1 and not b2 then op=1 end
			if b2 and not b1 then op=2 end
			if b1 and b2 then
				-- 选择操作方式：特殊召唤或装备
				op=aux.SelectFromOptions(tp,
					{b1,1152,1},
					{b2,1068,2})
			end
			-- 中断当前效果处理
			Duel.BreakEffect()
			if op==1 then
				-- 将该「电子龙」特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			elseif op==2 then
				-- 将该「电子龙」装备给此卡
				Duel.Equip(tp,tc,c)
				-- 设置装备限制效果，防止被其他卡装备
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				tc:RegisterEffect(e1)
			end
		end
	end
	-- ①效果的处理流程结束，设置回合内不能特殊召唤非机械族怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit2)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非机械族怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤非机械族怪兽的效果目标
function s.splimit2(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 设置装备限制效果的判断条件
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 筛选场上可返回手牌的「电子龙」
function s.costfilter(c)
	return c:IsFaceup() and c:IsCode(70095154) and c:IsAbleToHandAsCost()
end
-- ②效果的发动条件判断
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在可返回手牌的「电子龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1张「电子龙」返回手牌
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 显示所选卡被选为对象
	Duel.HintSelection(g)
	-- 将所选卡返回手牌作为费用
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 筛选卡组或墓地中的「融合」
function s.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- ②效果的发动条件判断
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组或墓地中是否存在「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息，表示将「融合」加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理流程
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地中选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选「融合」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方所选卡
		Duel.ConfirmCards(1-tp,g)
	end
end
