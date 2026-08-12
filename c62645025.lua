--幻影騎士団ウロング・マグネリング
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。那次攻击无效。那之后，这张卡变成持有以下效果的效果怪兽（战士族·暗·2星·攻/守0）在怪兽区域攻击表示特殊召唤（不当作陷阱卡使用）。
-- ●把这张卡以及自己场上的表侧表示的1只「幻影骑士团」怪兽或者1张「幻影」永续魔法·永续陷阱卡送去墓地才能发动。自己从卡组抽2张。这个效果在对方回合也能发动。
function c62645025.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。那次攻击无效。那之后，这张卡变成持有以下效果的效果怪兽（战士族·暗·2星·攻/守0）在怪兽区域攻击表示特殊召唤（不当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c62645025.condition)
	e1:SetTarget(c62645025.target)
	e1:SetOperation(c62645025.activate)
	c:RegisterEffect(e1)
	-- ●把这张卡以及自己场上的表侧表示的1只「幻影骑士团」怪兽或者1张「幻影」永续魔法·永续陷阱卡送去墓地才能发动。自己从卡组抽2张。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c62645025.drcon)
	e2:SetCost(c62645025.drcost)
	e2:SetTarget(c62645025.drtg)
	e2:SetOperation(c62645025.drop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件函数
function c62645025.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽的控制者是否为对方
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 定义①效果的发动准备（Target）函数
function c62645025.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否能将此卡作为特定属性、种族、等级的怪兽特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,62645025,0x10db,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) end
	-- 设置连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义①效果的效果处理（Operation）函数
function c62645025.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效攻击，若无效失败则效果处理中止
	if not Duel.NegateAttack() then return end
	-- 中断当前效果处理，使后续的特殊召唤不与无效攻击视为同时处理
	Duel.BreakEffect()
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e)
		-- 检查此卡是否仍存在于原本区域，且玩家是否仍能将其特殊召唤为怪兽，若不能则不处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,62645025,0x10db,TYPES_EFFECT_TRAP_MONSTER,0,0,2,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_ATTACK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT)
	-- 将此卡以自身效果在自己场上表侧攻击表示特殊召唤
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 定义抽卡效果的发动条件函数，检查此卡是否由自身效果特殊召唤
function c62645025.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 定义过滤函数，筛选自己场上表侧表示的「幻影骑士团」怪兽或「幻影」永续魔法·永续陷阱卡
function c62645025.cfilter(c)
	if c:IsFacedown() or not c:IsAbleToGraveAsCost() then return false end
	return (c:IsSetCard(0x10db) and c:IsType(TYPE_MONSTER))
		or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS))
end
-- 定义抽卡效果的Cost函数
function c62645025.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost()
		-- 检查场上是否存在除自身以外的、满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c62645025.cfilter,tp,LOCATION_ONFIELD,0,1,c) end
	-- 给玩家发送选择送去墓地的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张除自身以外的、满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c62645025.cfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	g:AddCard(c)
	-- 将选中的卡和自身送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义抽卡效果的发动准备（Target）函数
function c62645025.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以效果抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果影响的玩家为当前发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果影响的参数为2
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义抽卡效果的效果处理（Operation）函数
function c62645025.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
