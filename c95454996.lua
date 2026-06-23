--M∀LICE＜Q＞WHITE BINDER
-- 效果：
-- 包含「码丽丝」怪兽的怪兽2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己·对方的墓地的卡合计最多3张为对象才能发动。那些卡除外。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1张「码丽丝」陷阱卡在自己场上盖放。
-- ③：这张卡被除外的场合，支付900基本分才能发动。这张卡特殊召唤。那之后，自己可以抽1张。
local s,id,o=GetID()
-- 定义并注册卡片效果
function s.initial_effect(c)
	-- 添加连接召唤手续：包含「码丽丝」怪兽的怪兽2只以上
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
-- 连接素材过滤：检查素材中是否包含「码丽丝」怪兽
function s.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1bf)
end
-- 效果①的发动准备：选择墓地的卡作为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	-- 检查双方墓地是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己或对方墓地1到3张可以除外的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	-- 设置效果处理信息：除外选中的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：除外选中的对象
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetsRelateToChain()
	if tg:GetCount()>0 then
		-- 将目标卡片表侧表示除外
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤条件：卡组或墓地中可盖放的「码丽丝」陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1bf) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动准备：检查卡组或墓地是否有可盖放的「码丽丝」陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张满足条件的「码丽丝」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的效果处理：从卡组或墓地盖放「码丽丝」陷阱卡
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己的卡组或墓地选择1张不受王家长眠之谷影响的「码丽丝」陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- 效果③的发动代价：支付900基本分
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付900基本分
	if chk==0 then return Duel.CheckLPCost(tp,900) end
	-- 扣除玩家900基本分
	Duel.PayLPCost(tp,900)
end
-- 效果③的发动准备：检查是否能特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理：特殊召唤自身，并可选抽1张卡
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将此卡表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查玩家当前是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否选择抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否抽卡？"
		-- 中断当前效果，使之后的抽卡处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
