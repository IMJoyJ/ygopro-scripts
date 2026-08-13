--儀式魔人プレコグスター
-- 效果：
-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。把这张卡在仪式召唤使用的仪式怪兽给与对方基本分战斗伤害时，对方选择1张手卡丢弃。
function c4141820.initial_effect(c)
	-- 仪式怪兽的仪式召唤进行的场合，可以作为那次仪式召唤需要的等级数值的1只怪兽，把墓地存在的这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_RITUAL_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 把这张卡在仪式召唤使用的仪式怪兽给与对方基本分战斗伤害时，对方选择1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c4141820.condition)
	e2:SetOperation(c4141820.operation)
	c:RegisterEffect(e2)
end
-- 判定本次被作为素材的场合：必须用于仪式召唤（r==REASON_RITUAL），且此卡之前的所在位置不是超量素材区（避免在作为超量素材从场上被取下时误触发）。
function c4141820.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and not e:GetHandler():IsPreviousLocation(LOCATION_OVERLAY)
end
-- 遍历成为仪式素材的卡（eg），若该仪式怪兽还没被赋予此效果，则给它注册一个持续效果：在它给与对方战斗伤害时让对手丢弃1张手卡；同时用flag标记防止重复赋予。
function c4141820.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	while rc do
		if rc:GetFlagEffect(4141820)==0 then
			-- 把这张卡在仪式召唤使用的仪式怪兽给与对方基本分战斗伤害时，对方选择1张手卡丢弃。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(4141820,0))  --"「仪式魔人 预知者」效果适用中"
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_BATTLE_DAMAGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetLabel(ep)
			e1:SetCondition(c4141820.hdcon)
			e1:SetOperation(c4141820.hdop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			rc:RegisterEffect(e1,true)
			rc:RegisterFlagEffect(4141820,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=eg:GetNext()
	end
end
-- 触发条件：受到战斗伤害的玩家是仪式召唤者的对手（ep==1-e:GetLabel()），且造成战斗伤害的怪兽正是被附加效果的那只仪式怪兽（eg:GetFirst()==e:GetHandler()）。
function c4141820.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-e:GetLabel() and eg:GetFirst()==e:GetHandler()
end
-- 效果处理：展示此卡卡图，然后让受到战斗伤害的对方玩家选择并丢弃1张手卡（丢弃原因为效果丢弃）。
function c4141820.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 向所有玩家展示「仪式魔人 预知者」的卡图，作为此效果处理的提示。
	Duel.Hint(HINT_CARD,0,4141820)
	-- 让受到战斗伤害的对方玩家（1-e:GetLabel()）从手卡选择1张丢弃，丢弃理由为效果导致的丢弃。
	Duel.DiscardHand(1-e:GetLabel(),nil,1,1,REASON_EFFECT+REASON_DISCARD)
end
