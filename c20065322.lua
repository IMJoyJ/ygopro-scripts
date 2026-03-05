--クリボーを呼ぶ笛
-- 效果：
-- 把自己卡组1只「栗子球」或「羽翼栗子球」，加入手卡或者在自己场上特殊召唤。
function c20065322.initial_effect(c)
	-- 注册卡片代码列表，记录该卡可以检索或特殊召唤的卡片编号
	aux.AddCodeList(c,40640057)
	-- 把自己卡组1只「栗子球」或「羽翼栗子球」，加入手卡或者在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20065322.target)
	e1:SetOperation(c20065322.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「栗子球」或「羽翼栗子球」卡片，可加入手卡或特殊召唤
function c20065322.filter(c,ft,e,tp)
	return c:IsCode(40640057,57116033) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 判断是否可以发动此卡效果，检查卡组中是否存在符合条件的卡片
function c20065322.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检查卡组中是否存在至少1张满足过滤条件的卡片
		return Duel.IsExistingMatchingCard(c20065322.filter,tp,LOCATION_DECK,0,1,nil,ft,e,tp)
	end
end
-- 处理效果发动时的逻辑，选择目标卡片并决定是加入手卡还是特殊召唤
function c20065322.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 向玩家发送提示信息，提示选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择满足条件的1张卡片
	local g=Duel.SelectMatchingCard(tp,c20065322.filter,tp,LOCATION_DECK,0,1,1,nil,ft,e,tp)
	if g:GetCount()>0 then
		local th=g:GetFirst():IsAbleToHand()
		local sp=ft>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		-- 如果目标卡片既能加入手卡也能特殊召唤，则由玩家选择操作方式
		if th and sp then op=Duel.SelectOption(tp,1190,1152)
		elseif th then op=0
		else op=1 end
		if op==0 then
			-- 将选中的卡片送入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方确认送入手卡的卡片
			Duel.ConfirmCards(1-tp,g)
		else
			-- 将选中的卡片特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
