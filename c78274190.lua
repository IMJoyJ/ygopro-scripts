--超重輝将サン－5
-- 效果：
-- ←8 【灵摆】 8→
-- ①：自己墓地有魔法·陷阱卡存在的场合，这张卡的灵摆刻度变成4。
-- ②：1回合1次，自己的「超重武者」怪兽战斗破坏对方怪兽时才能发动。那只怪兽只再1次可以继续攻击。
-- 【怪兽效果】
-- 这张卡在规则上也当作「超重武者」卡使用。「超重辉将 珊瑚-5」的怪兽效果1回合只能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，把自己场上最多2只「超重武者」怪兽解放才能发动。自己从卡组抽出解放的数量。
function c78274190.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己墓地有魔法·陷阱卡存在的场合，这张卡的灵摆刻度变成4。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c78274190.sccon)
	e2:SetValue(4)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，自己的「超重武者」怪兽战斗破坏对方怪兽时才能发动。那只怪兽只再1次可以继续攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(78274190,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c78274190.catg)
	e4:SetOperation(c78274190.caop)
	c:RegisterEffect(e4)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，把自己场上最多2只「超重武者」怪兽解放才能发动。自己从卡组抽出解放的数量。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(78274190,1))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,78274190)
	e5:SetCondition(c78274190.condition)
	e5:SetCost(c78274190.cost)
	e5:SetTarget(c78274190.target)
	e5:SetOperation(c78274190.operation)
	c:RegisterEffect(e5)
end
-- 灵摆刻度变更效果的条件函数：自己墓地存在魔法·陷阱卡
function c78274190.sccon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查自己墓地是否存在至少1张魔法或陷阱卡
	return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：由自己控制、属于「超重武者」系列且当前可以进行追加攻击的怪兽
function c78274190.afilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x9a) and c:IsChainAttackable()
end
-- 追加攻击效果的发动检查与靶向函数：检查是否有符合条件的「超重武者」怪兽战斗破坏了怪兽，并将其设为效果处理对象
function c78274190.catg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c78274190.afilter,1,nil,tp) end
	local a=eg:Filter(c78274190.afilter,nil,tp):GetFirst()
	-- 将战斗破坏对方怪兽的己方「超重武者」怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(a)
end
-- 追加攻击效果的处理函数：若目标怪兽仍表侧表示存在于自己场上且与战斗相关，则使其可以再进行1次攻击
function c78274190.caop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果处理对象（即进行追加攻击的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToBattle() then
		-- 使该怪兽可以再进行1次攻击
		Duel.ChainAttack()
	end
end
-- 抽卡效果的发动条件函数：自己墓地没有魔法·陷阱卡存在
function c78274190.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查并确认自己墓地不存在任何魔法或陷阱卡
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 抽卡效果的代价函数：检查并选择自己场上最多2只「超重武者」怪兽解放，并记录实际解放的数量
function c78274190.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己场上是否存在至少1只可以解放的「超重武者」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x9a) end
	-- 获取自己卡组中剩余的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct>2 then ct=2 end
	-- 让玩家选择1到ct张（且最多为2张）可解放的「超重武者」怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,ct,nil,0x9a)
	-- 解放选中的怪兽作为发动代价，并获取实际解放的数量
	local rct=Duel.Release(g,REASON_COST)
	e:SetLabel(rct)
end
-- 抽卡效果的靶向与发动检查函数：确认玩家是否可以抽卡，并设置抽卡的操作信息
function c78274190.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认自己当前是否具有抽卡的效果执行许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁的操作信息为抽卡，抽卡数量为解放的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,e:GetLabel())
end
-- 抽卡效果的处理函数：从卡组抽出与解放数量相同的卡
function c78274190.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从卡组抽出等同于解放数量的卡
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
end
