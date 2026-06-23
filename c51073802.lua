--マジェスペクター・ポーキュパイン
-- 效果：
-- ←2 【灵摆】 2→
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，自己场上有「威风妖怪」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以自己墓地1张「威风妖怪」魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ③：只要这张卡在怪兽区域存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
local s,id,o=GetID()
-- 注册卡片的全部效果
function s.initial_effect(c)
	-- 为灵摆怪兽添加灵摆属性
	aux.EnablePendulumAttribute(c)
	-- 效果③：对方不能把这张卡作为效果的对象
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果③的过滤函数，使该效果只对对方的效果生效
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果③的过滤函数，使该效果只对对方的效果生效
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- 效果①：自己主要阶段，自己场上有「威风妖怪」怪兽存在的场合才能发动。这张卡从手卡特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_HAND)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 效果②：这张卡召唤·特殊召唤的场合，以自己墓地1张「威风妖怪」魔法卡为对象才能发动。那张卡在自己场上盖放
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"盖放魔法"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCountLimit(1,id+o)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(s.sstg)
	e4:SetOperation(s.ssop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
-- 检查场上的「威风妖怪」怪兽是否存在于场上的过滤函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd0)
end
-- 效果①的发动条件：当前阶段为主要阶段且己方场上存在「威风妖怪」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前阶段是否为主要阶段且己方场上存在「威风妖怪」怪兽
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动时点处理：检查是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查己方场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的发动效果：将此卡从手牌特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡是否还在场上，若是则执行特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 过滤墓地中的「威风妖怪」魔法卡的函数
function s.filter(c)
	return c:IsSetCard(0xd0) and c:IsSSetable() and c:IsType(TYPE_SPELL)
end
-- 效果②的发动时点处理：选择目标并设置操作信息
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查己方墓地中是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择一张满足条件的魔法卡作为目标
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要盖放此卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的发动效果：将选中的魔法卡盖放到场上
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 确认目标卡片是否还在连锁中，若是则执行盖放
	if tc:IsRelateToChain() then Duel.SSet(tp,tc) end
end
