--M∀LICE＜Q＞WHITE BINDER
-- 效果：
-- 包含「码丽丝」怪兽的怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1张「码丽丝」陷阱卡在自己场上盖放。
-- ③：这张卡被除外的场合，支付900基本分才能发动。这张卡特殊召唤。那之后，自己可以抽1张。
local s,id,o=GetID()
-- 初始化效果注册，包含连接召唤手续以及①②③效果的注册
function s.initial_effect(c)
	-- 设置连接召唤手续：包含「码丽丝」怪兽的怪兽2只以上
	aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1张「码丽丝」陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放陷阱"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，支付900基本分才能发动。这张卡特殊召唤。那之后，自己可以抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 连接召唤素材的检测过滤条件：必须包含「码丽丝」怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1bf)
end
-- ①效果（特殊召唤时除外墓地卡）的发动准备与目标选择
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 在发动时检查双方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己或对方墓地1到3张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置效果处理的分类为除外，目标为所选的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- ①效果（除外墓地的卡）的处理逻辑
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果关联且未受王家长眠之谷影响的卡片
	local tg=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if tg:GetCount()>0 then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤条件：卡组或墓地中的「码丽丝」陷阱卡且能在场上盖放
function s.setfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ②效果（盖放卡组·墓地「码丽丝」陷阱卡）的发动准备
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组或墓地中是否存在至少1张可盖放的「码丽丝」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- ②效果（盖放「码丽丝」陷阱卡）的效果处理逻辑
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己卡组或墓地选择1张受王家长眠之谷影响判定后的「码丽丝」陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- ③效果（除外时特殊召唤并抽卡）的Cost支付函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付900点基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 扣除玩家900点基本分
	Duel.PayLPCost(tp,900)
end
-- ③效果的发动准备与特召可能性的检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的分类为特殊召唤，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果（特殊召唤并抽卡）的效果处理逻辑
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡与效果关联，则将其表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查玩家当前是否能够进行抽卡
		and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否选择抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否抽卡？"
		-- 中断当前效果，使后续的抽卡处理视为不同时进行
		Duel.BreakEffect()
		-- 让玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
