--星彩の竜輝巧
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，以自己场上1只「龙辉巧」怪兽或者仪式怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力直到对方回合结束时下降1000，那只对方怪兽破坏。
function c57970721.initial_effect(c)
	-- ①：自己·对方的主要阶段，以自己场上1只「龙辉巧」怪兽或者仪式怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只自己怪兽的攻击力直到对方回合结束时下降1000，那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,57970721+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c57970721.condition)
	e1:SetTarget(c57970721.target)
	e1:SetOperation(c57970721.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数
function c57970721.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤自己场上表侧表示、攻击力在1000以上且属于「龙辉巧」或仪式怪兽的卡
function c57970721.filter(c)
	return c:IsFaceup() and (c:IsSetCard(0x154) or c:IsType(TYPE_RITUAL)) and c:IsAttackAbove(1000)
end
-- 定义效果的发动目标选择与合法性检测函数
function c57970721.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在发动时，检查自己场上是否存在符合条件的「龙辉巧」怪兽或仪式怪兽
	if chk==0 then return Duel.IsExistingTarget(c57970721.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且对方场上是否存在表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「龙辉巧」怪兽或仪式怪兽作为对象
	local g1=Duel.SelectTarget(tp,c57970721.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示怪兽作为对象
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 设置操作信息，表示此效果将破坏选中的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 定义效果的处理函数，执行攻击力下降和破坏怪兽的逻辑
function c57970721.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选为对象的所有卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	if tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsFaceup() and tc:IsAttackAbove(1000) then
		-- 那只自己怪兽的攻击力直到对方回合结束时下降1000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and lc:IsRelateToEffect(e) and lc:IsControler(1-tp) then
			-- 将选中的对方怪兽因效果破坏
			Duel.Destroy(lc,REASON_EFFECT)
		end
	end
end
