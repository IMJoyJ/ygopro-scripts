--X－セイバー ソウザ
-- 效果：
-- 调整＋调整以外的「X-剑士」怪兽1只以上
-- ①：把自己场上1只「X-剑士」怪兽解放，从以下效果选择1个才能发动。那个效果直到回合结束时得到。
-- ●这张卡和怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
-- ●这张卡不会被陷阱卡的效果破坏。
function c63612442.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的「X-剑士」怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x100d),1)
	c:EnableReviveLimit()
	-- ①：把自己场上1只「X-剑士」怪兽解放，从以下效果选择1个才能发动。那个效果直到回合结束时得到。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63612442,0))  --"选择一个效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c63612442.cost)
	e1:SetTarget(c63612442.target)
	e1:SetOperation(c63612442.operation)
	c:RegisterEffect(e1)
end
-- 起动效果的代价（Cost）函数：解放自己场上1只「X-剑士」怪兽
function c63612442.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除自身以外、可以解放的1只「X-剑士」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,e:GetHandler(),0x100d) end
	-- 选择自己场上除自身以外的1只「X-剑士」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,e:GetHandler(),0x100d)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 起动效果的判定（Target）函数：让玩家选择未获得过的效果，并为该效果注册标记
function c63612442.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(63612442)==0 or c:GetFlagEffect(63612443)==0 end
	local t1=c:GetFlagEffect(63612442)
	local t2=c:GetFlagEffect(63612443)
	local op=0
	-- 提示玩家选择一个效果
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(63612442,0))  --"选择一个效果"
	if t1==0 and t2==0 then
		-- 两个效果都未获得过时，让玩家在两个效果中选择一个
		op=Duel.SelectOption(tp,aux.Stringid(63612442,1),aux.Stringid(63612442,2))  --"这张卡和怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。/这张卡不会被陷阱卡的效果破坏。"
	-- 若只剩第一个效果未获得过，则只能选择第一个效果
	elseif t1==0 then op=Duel.SelectOption(tp,aux.Stringid(63612442,1))  --"这张卡和怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。"
	-- 若只剩第二个效果未获得过，则只能选择第二个效果
	else Duel.SelectOption(tp,aux.Stringid(63612442,2)) op=1 end  --"这张卡不会被陷阱卡的效果破坏。"
	e:SetLabel(op)
	if op==0 then c:RegisterFlagEffect(63612442,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	else c:RegisterFlagEffect(63612443,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1) end
end
-- 起动效果的处理（Operation）函数：根据玩家的选择，赋予这张卡对应的效果直到回合结束
function c63612442.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- ●这张卡和怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(63612442,3))  --"破坏战斗对象"
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e1:SetCode(EVENT_BATTLE_START)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetCondition(c63612442.descon)
		e1:SetTarget(c63612442.destg)
		e1:SetOperation(c63612442.desop)
		c:RegisterEffect(e1)
	else
		-- ●这张卡不会被陷阱卡的效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c63612442.efilter)
		c:RegisterEffect(e1)
	end
end
-- 战斗破坏效果的条件（Condition）函数：获取与这张卡进行战斗的对方怪兽，并确认其存在
function c63612442.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	-- 如果自身是被攻击的怪兽，则将战斗对手设定为攻击怪兽
	if d==e:GetHandler() then d=Duel.GetAttacker() end
	e:SetLabelObject(d)
	return d~=nil
end
-- 战斗破坏效果的判定（Target）函数：设置破坏操作的信息
function c63612442.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置破坏战斗对手的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetLabelObject(),1,0,0)
end
-- 战斗破坏效果的处理（Operation）函数：若战斗对手仍处于战斗状态，则将其破坏
function c63612442.desop(e,tp,eg,ep,ev,re,r,rp)
	local d=e:GetLabelObject()
	if d:IsRelateToBattle() then
		-- 将战斗对手怪兽破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
-- 陷阱抗性效果的过滤函数：判断效果源是否为陷阱卡
function c63612442.efilter(e,re)
	return re:GetOwner():IsType(TYPE_TRAP)
end
