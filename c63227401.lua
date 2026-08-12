--スキル・プリズナー
-- 效果：
-- 选择自己场上1张卡才能发动。这个回合，选择的卡为对象发动的怪兽效果无效。此外，把墓地的这张卡从游戏中除外，选择自己场上1张卡才能发动。这个回合，选择的卡为对象发动的怪兽效果无效。这个效果在这张卡送去墓地的回合不能发动。
function c63227401.initial_effect(c)
	-- 选择自己场上1张卡才能发动。这个回合，选择的卡为对象发动的怪兽效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(c63227401.target)
	e1:SetOperation(c63227401.activate)
	c:RegisterEffect(e1)
	-- 此外，把墓地的这张卡从游戏中除外，选择自己场上1张卡才能发动。这个回合，选择的卡为对象发动的怪兽效果无效。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63227401,0))  --"效果耐性"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 设置该效果在这张卡送去墓地的回合不能发动的限制条件
	e2:SetCondition(aux.exccon)
	-- 设置把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c63227401.target)
	e2:SetOperation(c63227401.activate)
	c:RegisterEffect(e2)
end
-- 效果发动的对象选择与合法性检测函数
function c63227401.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=e:GetHandler() end
	-- 在发动准备阶段，检查自己场上是否存在除这张卡以外的卡片作为合法的效果对象
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1张卡作为效果的对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
end
-- 效果处理函数，为目标卡片添加标记并注册全局无效化效果
function c63227401.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(63227401,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(63227401,1))  --"「技能禁锢」效果适用中"
		-- 这个回合，选择的卡为对象发动的怪兽效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(c63227401.discon)
		e1:SetOperation(c63227401.disop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		-- 在全局环境中注册该回合内持续适用的无效化效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断当前正在处理的连锁是否为以目标卡片为对象的怪兽效果
function c63227401.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(63227401)==0 or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前处理的连锁的效果对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsContains(tc) and re:IsActiveType(TYPE_MONSTER)
end
-- 执行无效化操作的函数
function c63227401.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前处理的连锁的效果无效
	Duel.NegateEffect(ev)
end
