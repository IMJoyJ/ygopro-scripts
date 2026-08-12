--天空の泉
-- 效果：
-- 光属性怪兽被战斗破坏送去自己墓地时，可以把那1只怪兽从游戏中除外，自己基本分回复那只怪兽的攻击力的数值。
function c92223641.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 光属性怪兽被战斗破坏送去自己墓地时，可以把那1只怪兽从游戏中除外，自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c92223641.cost)
	e2:SetTarget(c92223641.tg)
	e2:SetOperation(c92223641.op)
	c:RegisterEffect(e2)
end
-- 筛选出因战斗破坏送去自己墓地的光属性怪兽
function c92223641.filter(g,tp)
	local c=g:GetFirst()
	if c:IsControler(1-tp) then c=g:GetNext() end
	if c and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLocation(LOCATION_GRAVE) then return c end
	return nil
end
-- 发动代价：检测并获取满足条件的光属性怪兽，将其除外并记录其攻击力
function c92223641.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local rc=c92223641.filter(eg,tp)
		return rc and rc:IsAbleToRemoveAsCost()
	end
	local rc=c92223641.filter(eg,tp)
	e:SetLabel(rc:GetAttack())
	-- 将目标怪兽表侧表示除外
	Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
end
-- 设置效果处理时的目标玩家、回复数值及操作信息
function c92223641.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为记录的怪兽攻击力
	Duel.SetTargetParam(e:GetLabel())
	-- 设置当前连锁的操作信息为回复效果，指定玩家和回复数值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 效果处理：获取目标玩家和回复数值，执行回复生命值操作
function c92223641.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
