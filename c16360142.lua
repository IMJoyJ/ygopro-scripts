--斬機サブトラ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽的攻击力直到回合结束时下降1000。这个效果特殊召唤的回合，这张卡不能攻击。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤。
function c16360142.initial_effect(c)
	-- 创建效果1，设置为起动效果，只能在手卡发动，取对象，限制1回合1次，目标为场上1只表侧表示怪兽，效果发动时特殊召唤自己
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,16360142)
	e1:SetTarget(c16360142.sptg)
	e1:SetOperation(c16360142.spop)
	c:RegisterEffect(e1)
end
-- 检查是否满足特殊召唤条件，包括手卡中卡能特殊召唤、场上怪兽区有空位、场上存在1只表侧表示怪兽
function c16360142.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家场上怪兽区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在1只表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择1只表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理效果发动后的操作，包括特殊召唤自身、设置不能攻击效果、设置对象怪兽攻击力下降1000、设置不能从额外卡组特殊召唤非电子界族怪兽
function c16360142.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否还在场上，若在则特殊召唤此卡
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置此卡在特殊召唤的回合不能攻击的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 获取当前连锁的效果对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 设置对象怪兽的攻击力下降1000的效果
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-1000)
			tc:RegisterEffect(e1)
		end
	end
	-- 设置直到回合结束时自己不是电子界族怪兽不能从额外卡组特殊召唤的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c16360142.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制不能特殊召唤的怪兽条件为非电子界族且在额外卡组
function c16360142.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE) and c:IsLocation(LOCATION_EXTRA)
end
