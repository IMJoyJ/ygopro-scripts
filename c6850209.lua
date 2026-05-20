--デーモンとの駆け引き
-- 效果：
-- 这张卡只能在有8星以上的怪兽从自己场上被送去墓地的回合发动。从自己的手卡或卡组特殊召唤「狂暴死龙」上场。
function c6850209.initial_effect(c)
	-- 从自己的手卡或卡组特殊召唤「狂暴死龙」上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c6850209.target)
	e1:SetOperation(c6850209.activate)
	c:RegisterEffect(e1)
	if not c6850209.global_check then
		c6850209.global_check=true
		c6850209[0]=false
		c6850209[1]=false
		-- 有8星以上的怪兽从自己场上被送去墓地
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c6850209.checkop)
		-- 注册全局效果，用于监测是否有怪兽送去墓地
		Duel.RegisterEffect(ge1,0)
		-- 这张卡只能在有8星以上的怪兽从自己场上被送去墓地的回合发动。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c6850209.clear)
		-- 注册全局效果，在每个回合开始时重置发动条件标记
		Duel.RegisterEffect(ge2,0)
	end
end
-- 检查是否有8星以上的怪兽从场上送去墓地，并记录其原本控制者
function c6850209.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		if tc:IsLevelAbove(8) and tc:IsPreviousLocation(LOCATION_MZONE) then
			c6850209[tc:GetPreviousControler()]=true
		end
		tc=eg:GetNext()
	end
end
-- 每个回合开始时，重置双方玩家的送墓记录标记
function c6850209.clear(e,tp,eg,ep,ev,re,r,rp)
	c6850209[0]=false
	c6850209[1]=false
end
-- 过滤卡组或手牌中可以特殊召唤的「狂暴死龙」
function c6850209.filter(c,e,tp)
	return c:IsCode(85605684) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动的合法性检测与操作信息设置
function c6850209.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否有8星以上怪兽从场上送去墓地，且自己场上有空余的怪兽区域
	if chk==0 then return c6850209[tp] and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		-- 检查手卡或卡组是否存在至少1张可以特殊召唤的「狂暴死龙」
		Duel.IsExistingMatchingCard(c6850209.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：从手卡或卡组特殊召唤「狂暴死龙」
function c6850209.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1张「狂暴死龙」
	local g=Duel.SelectMatchingCard(tp,c6850209.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
