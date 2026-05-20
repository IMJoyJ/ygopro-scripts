--インフェルニティガン
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从自己手卡选1只「永火」怪兽送去墓地。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地最多2只「永火」怪兽为对象才能发动（这个效果在自己手卡是0张的场合才能发动和处理）。那些怪兽特殊召唤。
function c66957584.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段才能发动。从自己手卡选1只「永火」怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66957584,0))  --"手卡「永火」怪兽送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c66957584.distg)
	e2:SetOperation(c66957584.disop)
	c:RegisterEffect(e2)
	-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己墓地最多2只「永火」怪兽为对象才能发动（这个效果在自己手卡是0张的场合才能发动和处理）。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66957584,1))  --"墓地「永火」怪兽特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c66957584.spcon)
	e3:SetCost(c66957584.spcost)
	e3:SetTarget(c66957584.sptg)
	e3:SetOperation(c66957584.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡中可以送去墓地的「永火」怪兽
function c66957584.disfilter(c)
	return c:IsSetCard(0xb) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果①的发动准备与合法性检测函数
function c66957584.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检测自己手卡是否存在至少1只满足条件的「永火」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66957584.disfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为：将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,0)
end
-- 效果①的效果处理（送去墓地）函数
function c66957584.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择卡片时的提示信息为“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡选择1只满足条件的「永火」怪兽
	local g=Duel.SelectMatchingCard(tp,c66957584.disfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 若选出了卡，则因效果将这些卡送去墓地
	if g:GetCount()>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end
-- 效果②的发动条件：自己手卡是0张
function c66957584.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己手卡数量是否等于0
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果②的发动代价（Cost）处理函数
function c66957584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将作为发动代价的这张卡（永火炮）送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤条件：墓地中可以特殊召唤的「永火」怪兽
function c66957584.filter(c,e,tp)
	return c:IsSetCard(0xb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与选择对象函数
function c66957584.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c66957584.filter(chkc,e,tp) end
	-- 在发动阶段检测自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检测自己墓地是否存在至少1只可以特殊召唤的「永火」怪兽
		and Duel.IsExistingTarget(c66957584.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取自己场上可用的怪兽区域空格数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地最多为可用空格数（且最多2只）的「永火」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66957584.filter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置当前连锁的操作信息为：将选中的对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果②的效果处理（特殊召唤）函数
function c66957584.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时检测手卡是否为0张，若不为0则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then return end
	-- 获取当前自己场上可用的怪兽区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or ft<sg:GetCount() or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	-- 将仍符合条件的对象怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
