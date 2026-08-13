--A★スペキュレーション
-- 效果：
-- 攻击力2500以上的怪兽＋守备力2500以下的里侧守备表示怪兽
-- 自己对「A★黑桃之猜大小剑士」1回合只能有1次特殊召唤。
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：这张卡的攻击力上升对方场上的怪兽的最高原本攻击力数值。
-- ●守备表示：这张卡不会被战斗·效果破坏。
-- ②：把1只攻击表示怪兽和1只里侧守备表示怪兽从自己场上解放才能发动。这张卡从墓地特殊召唤。
function c10796448.initial_effect(c)
	c:SetSPSummonOnce(10796448)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只攻击力2500以上的怪兽和1只守备力2500以下的里侧守备表示怪兽作为融合素材。
	aux.AddFusionProcFun2(c,c10796448.ffilter1,c10796448.ffilter2,true)
	-- ●攻击表示：这张卡的攻击力上升对方场上的怪兽的最高原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c10796448.atkcon)
	e1:SetValue(c10796448.val)
	c:RegisterEffect(e1)
	-- ●守备表示：这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c10796448.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ②：把1只攻击表示怪兽和1只里侧守备表示怪兽从自己场上解放才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCost(c10796448.spcost)
	e4:SetTarget(c10796448.sptg)
	e4:SetOperation(c10796448.spop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤器1：判定怪兽是否攻击力在2500以上，用于选择融合素材中的攻击力2500以上的怪兽。
function c10796448.ffilter1(c)
	return c:IsAttackAbove(2500)
end
-- 融合素材过滤器2：判定怪兽是否守备力在2500以下、里侧守备表示且在怪兽区域，用于选择融合素材中的里侧守备表示怪兽。
function c10796448.ffilter2(c)
	return c:IsDefenseBelow(2500) and c:IsFacedown() and c:IsDefensePos() and c:IsLocation(LOCATION_MZONE)
end
-- 攻击力上升效果的适用条件：检查这张卡当前的表示形式是否为攻击表示。
function c10796448.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 攻击力上升数值的计算：检索对方场上表侧表示怪兽，取其最高原本攻击力作为上升值；若无怪兽则上升0。
function c10796448.val(e,c)
	-- 获取对方场上所有表侧表示怪兽的集合（以效果持有者视角的对方怪兽区）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetOwnerPlayer(),0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetBaseAttack)
		return val
	end
end
-- 不破坏效果的适用条件：检查这张卡当前的表示形式是否为守备表示。
function c10796448.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- ②效果的代价筛选：选择可解放且表示形式为表侧攻击表示或里侧守备表示的怪兽。
function c10796448.costfilter(c)
	return c:IsReleasable() and ((c:IsFacedown() and c:IsDefensePos()) or (c:IsFaceup() and c:IsAttackPos()))
end
-- 检查所选2张解放素材是否满足：解放后自己怪兽区仍有空位，且素材恰好包含1只表侧攻击表示和1只里侧守备表示怪兽。
function c10796448.spcheck(g,tp)
	-- 具体判定：解放后空余怪兽区数量>0，且素材组中存在表侧攻击表示与里侧守备表示各1只。
	return Duel.GetMZoneCount(tp,g)>0 and aux.gfcheck(g,Card.IsPosition,POS_FACEUP_ATTACK,POS_FACEDOWN_DEFENSE)
end
-- ②效果的代价支付：在发动时从自己场上选择1只攻击表示怪兽和1只里侧守备表示怪兽解放作为发动代价。
function c10796448.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己场上所有满足代价筛选条件（可解放且表侧攻击表示或里侧守备表示）的怪兽集合。
	local g=Duel.GetMatchingGroup(c10796448.costfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(c10796448.spcheck,2,2,tp) end
	-- 显示选择提示，提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local sg=g:SelectSubGroup(tp,c10796448.spcheck,false,2,2,tp)
	-- 将选中的素材卡作为代价解放（REASON_COST），完成发动代价的支付。
	Duel.Release(sg,REASON_COST)
end
-- ②效果的目标阶段：确认墓地中的这张卡能否被特殊召唤，并设置特殊召唤的操作信息。
function c10796448.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 声明本次处理将进行特殊召唤，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理：若这张卡仍与效果关联，则将其从墓地特殊召唤到自己场上。
function c10796448.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到其持有者场上，并正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
