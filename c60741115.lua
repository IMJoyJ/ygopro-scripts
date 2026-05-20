--ダメージ・イーター
-- 效果：
-- 对方把给与伤害的魔法·陷阱·效果怪兽的效果发动时，把墓地存在的这张卡从游戏中除外才能发动。那个效果变成基本分回复效果。这个效果在对方回合才能发动。
function c60741115.initial_effect(c)
	-- 对方把给与伤害的魔法·陷阱·效果怪兽的效果发动时，把墓地存在的这张卡从游戏中除外才能发动。那个效果变成基本分回复效果。这个效果在对方回合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60741115,0))  --"伤害回复"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c60741115.condition)
	-- 将墓地的这张卡除外作为发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetOperation(c60741115.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：对方在对方回合发动了给予伤害的效果，或者发动了因受到‘回复变伤害’影响而实际会造成伤害的回复效果
function c60741115.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 如果发动效果的玩家是自己，或者当前是自己的回合，则不能发动
	if rp==tp or Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前连锁中关于‘给予伤害’的效果处理信息
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex then return true end
	-- 获取当前连锁中关于‘回复生命值’的效果处理信息
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	if not ex then return false end
	-- 如果回复对象不是双方，则检查该对象玩家是否受到‘回复变伤害’效果的影响
	if cp~=PLAYER_ALL then return Duel.IsPlayerAffectedByEffect(cp,EFFECT_REVERSE_RECOVER)
	-- 如果回复对象是双方，则检查先手玩家是否受到‘回复变伤害’效果的影响
	else return Duel.IsPlayerAffectedByEffect(0,EFFECT_REVERSE_RECOVER)
		-- 或者检查后手玩家是否受到‘回复变伤害’效果的影响
		or Duel.IsPlayerAffectedByEffect(1,EFFECT_REVERSE_RECOVER)
	end
end
-- 效果处理：创建一个在当前连锁内适用的‘伤害变回复’的全局效果并注册
function c60741115.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前触发效果的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果变成基本分回复效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetTargetRange(1,1)
	e1:SetValue(c60741115.rev)
	e1:SetReset(RESET_CHAIN)
	e1:SetLabel(cid)
	-- 将‘伤害变回复’的效果注册给系统环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前产生伤害的事件是否属于被此卡效果指定的连锁，且该伤害是由效果引起的
function c60741115.rev(e,re,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return false end
	-- 获取当前正在处理的连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
