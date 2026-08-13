--補充部隊
-- 效果：
-- ①：每次对方怪兽的攻击或者对方的效果让自己受到1000以上的伤害发动。那次伤害每有1000，自己从卡组抽1张。
function c28486799.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次对方怪兽的攻击或者对方的效果让自己受到1000以上的伤害发动。那次伤害每有1000，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c28486799.drcon)
	e2:SetTarget(c28486799.drtg)
	e2:SetOperation(c28486799.drop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：自己受到伤害、伤害来自对方（对方的怪兽攻击或对方的效果），且伤害数值为1000以上。
function c28486799.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and rp==1-tp and ev>=1000
		-- 伤害来源判定：如果是效果伤害则re存在；如果是战斗伤害则攻击怪兽的控制者为对方，即对方怪兽的攻击。
		and (re or (Duel.GetAttacker() and Duel.GetAttacker():IsControler(1-tp)))
end
-- 发动时设定：计算抽卡张数d（伤害数值除以1000取整），将对象玩家设为自己，对象参数设为d，并声明此次效果将进行抽卡。
function c28486799.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=math.floor(ev/1000)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为tp（自己），表示抽卡玩家是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为d，表示抽卡张数为d（每满1000伤害抽1张）。
	Duel.SetTargetParam(d)
	-- 设置操作信息：声明本次效果处理将进行抽卡，对象玩家为tp，预计抽卡数量为d，因不取对象所以targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
-- 效果处理阶段：读取之前设定的对象玩家和抽卡张数，若d大于0则让该玩家以效果原因抽d张卡。
function c28486799.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的对象玩家和对象参数，分别赋值给p和d，即获取由谁抽卡以及抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if d>0 then
		-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡，完成实际抽卡动作。
		Duel.Draw(p,d,REASON_EFFECT)
	end
end
