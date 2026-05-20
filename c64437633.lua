--儀水鏡の幻影術
-- 效果：
-- 从手卡把1只名字带有「遗式」的仪式怪兽特殊召唤。这个效果特殊召唤的仪式怪兽不能攻击，结束阶段时回到持有者手卡。
function c64437633.initial_effect(c)
	-- 从手卡把1只名字带有「遗式」的仪式怪兽特殊召唤。这个效果特殊召唤的仪式怪兽不能攻击，结束阶段时回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c64437633.target)
	e1:SetOperation(c64437633.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中名字带有「遗式」的仪式怪兽
function c64437633.filter(c,e,tp)
	return c:IsSetCard(0x3a) and bit.band(c:GetType(),0x81)==0x81 and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 效果发动的可行性检查
function c64437633.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c64437633.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 效果处理：从手卡特殊召唤「遗式」仪式怪兽并添加后续限制
function c64437633.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c64437633.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)
		-- 这个效果特殊召唤的仪式怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		-- 结束阶段时回到持有者手卡。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetOperation(c64437633.retop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		tc:RegisterEffect(e2,true)
	end
end
-- 结束阶段时将怪兽送回手卡的处理函数
function c64437633.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将怪兽送回持有者手卡
	Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
end
