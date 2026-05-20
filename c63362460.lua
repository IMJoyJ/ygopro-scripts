--D-HERO ディバインガイ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击宣言时，以对方场上1张表侧表示的魔法卡为对象才能发动。那张卡破坏，给与对方500伤害。
-- ②：自己手卡是0张的场合，从自己墓地把这张卡和1只「命运英雄」怪兽除外才能发动。自己从卡组抽2张。这个效果在这张卡送去墓地的回合不能发动。
function c63362460.initial_effect(c)
	-- ①：这张卡的攻击宣言时，以对方场上1张表侧表示的魔法卡为对象才能发动。那张卡破坏，给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63362460,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(c63362460.destg)
	e1:SetOperation(c63362460.desop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己手卡是0张的场合，从自己墓地把这张卡和1只「命运英雄」怪兽除外才能发动。自己从卡组抽2张。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63362460,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,63362460)
	e2:SetCondition(c63362460.drcon)
	e2:SetCost(c63362460.drcost)
	e2:SetTarget(c63362460.drtg)
	e2:SetOperation(c63362460.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：对方场上表侧表示的魔法卡
function c63362460.desfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL)
end
-- 效果①的发动准备（检查并选择要破坏的魔法卡，设置破坏与伤害的操作信息）
function c63362460.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c63362460.desfilter(chkc) end
	-- 检查对方场上是否存在至少1张表侧表示的魔法卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(c63362460.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张表侧表示的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c63362460.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息：给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果①的效果处理（破坏对象卡片并给与对方伤害）
function c63362460.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡片是否仍与效果相关，并将其破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 给与对方500点伤害
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end
-- 效果②的发动条件判定（手卡为0张且不在送去墓地的回合）
function c63362460.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己手卡数量是否为0，且当前回合不是该卡送去墓地的回合
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and aux.exccon(e)
end
-- 过滤条件：墓地中可作为cost除外的「命运英雄」怪兽
function c63362460.cfilter(c)
	return c:IsSetCard(0xc008) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价处理（将自身和墓地1只「命运英雄」怪兽除外）
function c63362460.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在除自身以外的「命运英雄」怪兽作为除外代价
		and Duel.IsExistingMatchingCard(c63362460.cfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只除自身以外的「命运英雄」怪兽
	local g=Duel.SelectMatchingCard(tp,c63362460.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选中的怪兽和这张卡从墓地除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备（检查是否能抽卡，并设置抽卡的操作信息）
function c63362460.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果影响的玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置效果处理信息：自己抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果②的效果处理（执行抽卡）
function c63362460.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
