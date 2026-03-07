--ヒーロー・キッズ
-- 效果：
-- 这张卡特殊召唤成功时，可以从卡组特殊召唤任意数量的「英雄小子」。
function c32679370.initial_effect(c)
	-- 效果原文内容：这张卡特殊召唤成功时，可以从卡组特殊召唤任意数量的「英雄小子」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32679370,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c32679370.target)
	e1:SetOperation(c32679370.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的「英雄小子」卡片
function c32679370.filter(c,e,tp)
	return c:IsCode(32679370) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：判断是否可以发动此效果
function c32679370.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断卡组中是否存在满足条件的「英雄小子」
		and Duel.IsExistingMatchingCard(c32679370.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 效果作用：设置连锁操作信息，提示将要特殊召唤卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：处理特殊召唤效果的发动
function c32679370.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家场上可用的召唤区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：向玩家发送选择提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的「英雄小子」卡片
	local g=Duel.SelectMatchingCard(tp,c32679370.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
