--融合強兵
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从自己的额外卡组·墓地特殊召唤。这个效果特殊召唤的怪兽直到对方回合结束时不能攻击，效果无效化。
local s,id,o=GetID()
-- 定义卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从自己的额外卡组·墓地特殊召唤。这个效果特殊召唤的怪兽直到对方回合结束时不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤额外卡组中可以给对方观看的融合怪兽
function s.ffilter(c,e,tp)
	return c:IsType(TYPE_FUSION)
		-- 检查自己的额外卡组或墓地是否存在该融合怪兽记述的、且能特殊召唤的融合素材怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,c,e,tp)
end
-- 过滤满足特殊召唤条件的融合素材怪兽
function s.spfilter(c,fc,e,tp)
	-- 检查怪兽卡名是否被记述在融合怪兽的素材列表中，且该怪兽是否可以被特殊召唤
	if not (aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查从额外卡组特殊召唤该怪兽所需的额外怪兽区域空格是否足够
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查从墓地特殊召唤该怪兽所需的主要怪兽区域空格是否足够
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
end
-- 效果发动时的目标选择与合法性检查函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以给对方观看的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从额外卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择额外卡组中1只满足条件的融合怪兽
	local tc=Duel.SelectMatchingCard(tp,s.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的融合怪兽给对方玩家确认
		Duel.ConfirmCards(1-tp,tc)
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从额外卡组或墓地选择1只该融合怪兽记述的融合素材怪兽（受王家之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,tc,e,tp)
		-- 将选中的怪兽以表侧表示特殊召唤，并检查是否特殊召唤成功
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
			local c=e:GetHandler()
			local sc=g:GetFirst()
			-- 这个效果特殊召唤的怪兽直到对方回合结束时不能攻击，效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			sc:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE)
			sc:RegisterEffect(e2,true)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			sc:RegisterEffect(e3,true)
		end
	end
end
