--静寂のサイコソーサレス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，支付1000基本分才能发动。自己的卡组·墓地·除外状态的1张「瞬间移动」通常·速攻魔法卡在自己场上盖放。
-- ②：同调召唤的这张卡被送去墓地的场合，以对方场上1张卡为对象才能发动（念动力族的融合·同调怪兽的其中任意种在自己场上存在的场合，这个效果的对象可以变成2张）。那张卡回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册同调召唤手续、①效果（同调召唤成功时盖放「瞬间移动」魔陷）和②效果（同调召唤的此卡送墓时让对方卡回到手卡）。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，支付1000基本分才能发动。自己的卡组·墓地·除外状态的1张「瞬间移动」通常·速攻魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetCost(s.setcost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合，以对方场上1张卡为对象才能发动（念动力族的融合·同调怪兽的其中任意种在自己场上存在的场合，这个效果的对象可以变成2张）。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 检查此卡是否是通过同调召唤特殊召唤的。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 定义①效果的支付代价函数。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检查阶段，检查玩家是否能够支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 在发动效果时，让玩家支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- 过滤自己卡组、墓地、除外状态中属于「瞬间移动」且可以盖放的通常·速攻魔法卡。
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1cc) and (c:GetType()==TYPE_SPELL or c:IsType(TYPE_QUICKPLAY)) and c:IsSSetable()
end
-- 定义①效果的靶向与发动条件检查函数。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检查阶段，检查自己的卡组、墓地、除外状态是否存在至少1张满足条件的「瞬间移动」通常·速攻魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
-- 定义①效果的效果处理函数。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要盖放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组、墓地、除外状态中选择1张满足条件的「瞬间移动」通常·速攻魔法卡（适用王家之谷的过滤效果）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡片在自己场上盖放。
		Duel.SSet(tp,tc)
	end
end
-- 检查此卡是否是从怪兽区域送去墓地，且是否为同调召唤的这张卡。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤自己场上表侧表示的念动力族融合或同调怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
-- 定义②效果的靶向与对象选择函数。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 检查自己场上是否存在念动力族的融合·同调怪兽，若存在则将可选对象数量上限设为2。
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		ct=2
	end
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在发动效果的检查阶段，检查对方场上是否存在至少1张可以回到手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，要求选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张或最多2张可以回到手卡的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息，表明此效果的处理为将选中的卡片送回手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义②效果的效果处理函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToChain,nil)
	if tg:GetCount()>0 then
		-- 将仍存在于场上的对象卡片送回持有者的手卡。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
