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
	-- 添加融合召唤手续，使用满足ffilter1和ffilter2条件的怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c10796448.ffilter1,c10796448.ffilter2,true)
	-- ①：这张卡得到表示形式的以下效果。●攻击表示：这张卡的攻击力上升对方场上的怪兽的最高原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c10796448.atkcon)
	e1:SetValue(c10796448.val)
	c:RegisterEffect(e1)
	-- ①：这张卡得到表示形式的以下效果。●守备表示：这张卡不会被战斗·效果破坏。
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
-- 融合素材条件1：攻击力2500以上的怪兽
function c10796448.ffilter1(c)
	return c:IsAttackAbove(2500)
end
-- 融合素材条件2：守备力2500以下的里侧守备表示怪兽
function c10796448.ffilter2(c)
	return c:IsDefenseBelow(2500) and c:IsFacedown() and c:IsDefensePos() and c:IsLocation(LOCATION_MZONE)
end
-- 判断是否为攻击表示
function c10796448.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 计算对方场上怪兽最高原本攻击力数值
function c10796448.val(e,c)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetOwnerPlayer(),0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then
		return 0
	else
		local tg,val=g:GetMaxGroup(Card.GetBaseAttack)
		return val
	end
end
-- 判断是否为守备表示
function c10796448.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 解放条件过滤器：可解放的怪兽（攻击表示或里侧守备表示）
function c10796448.costfilter(c)
	return c:IsReleasable() and ((c:IsFacedown() and c:IsDefensePos()) or (c:IsFaceup() and c:IsAttackPos()))
end
-- 特殊召唤条件检查函数：判断所选怪兽是否满足攻击表示和里侧守备表示的组合
function c10796448.spcheck(g,tp)
	-- 检查所选怪兽组合是否满足特殊召唤条件：场上怪兽数量大于0且满足位置组合
	return Duel.GetMZoneCount(tp,g)>0 and aux.gfcheck(g,Card.IsPosition,POS_FACEUP_ATTACK,POS_FACEDOWN_DEFENSE)
end
-- 特殊召唤发动时的费用处理函数
function c10796448.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有可解放的怪兽
	local g=Duel.GetMatchingGroup(c10796448.costfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:CheckSubGroup(c10796448.spcheck,2,2,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:SelectSubGroup(tp,c10796448.spcheck,false,2,2,tp)
	-- 解放所选的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 特殊召唤发动时的目标设定函数
function c10796448.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤发动时的处理函数
function c10796448.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
