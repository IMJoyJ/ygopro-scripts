--禰須三破鳴比
-- 效果：
-- 这张卡不能作为融合·同调·超量·连接召唤的素材。
-- ①：这张卡召唤·特殊召唤成功的场合发动。给这张卡放置6个指示物。
-- ②：自己结束阶段发动。这张卡的控制权移给对方。
-- ③：1回合1次，有指示物放置的这张卡的控制权转移的场合发动。掷1次骰子，这张卡的指示物把最多有出现数目的数量尽可能取除。这个效果让这张卡的指示物全部被取除的场合，这张卡破坏，自己受到2000伤害。
function c71459017.initial_effect(c)
	c:EnableCounterPermit(0x58)
	-- 这张卡不能作为融合·同调·超量·连接召唤的素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(c71459017.fuslimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e4)
	-- ①：这张卡召唤·特殊召唤成功的场合发动。给这张卡放置6个指示物。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(71459017,0))  --"放置指示物"
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetOperation(c71459017.countop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	-- ②：自己结束阶段发动。这张卡的控制权移给对方。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(71459017,1))  --"转移控制权"
	e7:SetCategory(CATEGORY_CONTROL)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(c71459017.ctrcon)
	e7:SetTarget(c71459017.ctrtg)
	e7:SetOperation(c71459017.ctrop)
	c:RegisterEffect(e7)
	-- ③：1回合1次，有指示物放置的这张卡的控制权转移的场合发动。掷1次骰子，这张卡的指示物把最多有出现数目的数量尽可能取除。这个效果让这张卡的指示物全部被取除的场合，这张卡破坏，自己受到2000伤害。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(71459017,2))
	e8:SetCategory(CATEGORY_DICE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_CONTROL_CHANGED)
	e8:SetCountLimit(1)
	e8:SetCondition(c71459017.dicecon)
	e8:SetTarget(c71459017.dicetg)
	e8:SetOperation(c71459017.diceop)
	c:RegisterEffect(e8)
end
-- 融合素材限制条件函数，判断是否作为融合召唤的素材
function c71459017.fuslimit(e,c,sumtype)
	return sumtype&SUMMON_TYPE_FUSION==SUMMON_TYPE_FUSION
end
-- 给这张卡放置6个指示物的效果处理
function c71459017.countop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:AddCounter(0x58,6)
	end
end
-- 控制权转移效果的发动条件：当前回合是自己的回合
function c71459017.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 控制权转移效果的靶指向与操作信息设置
function c71459017.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：转移这张卡的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 控制权转移效果的具体操作：将这张卡移给对方
function c71459017.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 让对方玩家获得这张卡的控制权
		Duel.GetControl(c,1-tp)
	end
end
-- 掷骰子效果的发动条件：这张卡有指示物放置
function c71459017.dicecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x58)>0
end
-- 设置掷骰子效果的操作信息
function c71459017.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：进行1次掷骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 掷骰子效果的具体操作：掷骰子并取除对应数量的指示物，若指示物全部被取除则破坏此卡并给予伤害
function c71459017.diceop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsCanRemoveCounter(tp,0x58,1,REASON_EFFECT) then
		-- 进行1次掷骰子并获取结果
		local dc=Duel.TossDice(tp,1)
		if dc>c:GetCounter(0x58) then dc=c:GetCounter(0x58) end
		c:RemoveCounter(tp,0x58,dc,REASON_EFFECT)
		-- 判断这张卡的指示物是否全部被取除，若是则破坏这张卡
		if c:GetCounter(0x58)==0 and Duel.Destroy(c,REASON_EFFECT)~=0 then
			-- 给与自己2000点效果伤害
			Duel.Damage(tp,2000,REASON_EFFECT)
		end
	end
end
