--メルフィーゴッド・マミィ
-- 效果：
-- 兽族2星怪兽×3只以上
-- 「童话动物神仙教母·魔魅妈咪」1回合1次也能在自己场上的「童话动物·魔魅妈咪」上面重叠来超量召唤。
-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「童话动物」魔法·陷阱卡加入手卡。
-- ②：这张卡的攻击力上升这张卡作为超量素材中的「童话动物」怪兽的攻击力·守备力的合计数值。
-- ③：把这张卡5个超量素材取除才能发动。对方场上的卡全部回到手卡。
local s,id,o=GetID()
-- 注册超量召唤手续、限制及效果①（特召时检索）、效果②（素材加攻）、效果③（去5素材弹全场）
function s.initial_effect(c)
	-- 在卡片关系中记录这张卡记述了卡片密码为76833149（童话动物·魔魅妈咪）的卡片
	aux.AddCodeList(c,76833149)
	aux.AddXyzProcedure(c,s.mfilter,2,3,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)  --"是否在「童话动物·魔魅妈咪」上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从自己的卡组·墓地把1张「童话动物」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡作为超量素材中的「童话动物」怪兽的攻击力·守备力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ③：把这张卡5个超量素材取除才能发动。对方场上的卡全部回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.thcost2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- 超量素材过滤：等级2的兽族怪兽
function s.mfilter(c)
	return c:IsRace(RACE_BEAST)
end
-- 超量叠放判定过滤：场上表侧表示的「童话动物·魔魅妈咪」
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(76833149)
end
-- 在「童话动物·魔魅妈咪」上重叠进行超量召唤的限制判定与注册
function s.xyzop(e,tp,chk)
	-- 若为重叠超量召唤发动检查（chk==0），判定本回合是否尚未用该方式特殊召唤过此卡
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 重叠超量召唤成功时，注册回合重叠超量召唤的全局标识效果
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤条件：卡组或墓地中可以加入手牌的「童话动物」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动判定与检索：检查卡组或墓地是否存在可以检索的「童话动物」魔陷
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为效果发动的检查（chk==0），判定己方卡组或墓地中是否存在可检索的「童话动物」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从卡组或墓地将1张目标魔陷加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果①的效果处理：从己方的卡组或墓地选择1张「童话动物」魔法·陷阱卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地中选择1张不受王家长眠之谷影响的「童话动物」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选择的魔法·陷阱卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：超量素材中属于「童话动物」的怪兽卡
function s.cafilter(c)
	return c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER)
end
-- 效果②的计算函数：计算这张卡的超量素材中「童话动物」怪兽攻击力与守备力的合计数值
function s.atkval(e,c)
	local og=c:GetOverlayGroup():Filter(s.cafilter,nil)
	return og:GetSum(Card.GetAttack)+og:GetSum(Card.GetDefense)
end
-- 效果③的Cost处理：取除这张卡的5个超量素材
function s.thcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,5,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,5,5,REASON_COST)
end
-- 效果③的发动判定：检查对方场上是否存在可返回手牌的卡，并设置操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上所有能返回手牌的卡片组（除去自身）
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：将对方场上所有卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果③的效果处理：将对方场上的卡全部送回手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的卡片组
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	-- 将对方场上的所有卡送回手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
