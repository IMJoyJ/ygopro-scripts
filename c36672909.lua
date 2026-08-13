--再世律
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有原本攻击力或原本守备力是2500的怪兽存在的场合，以对方场上1张卡为对象才能发动（自己场上有「创世之神 狄特罗诺米安」存在的场合，这个效果的对象可以变成2张）。那张卡除外。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从手卡把1只攻击力或守备力是2500的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册：登记卡名「创世之神 狄特罗诺米安」；创建并注册效果①（发动除外）和效果②（墓地特殊召唤），均设为一回合一次。
function s.initial_effect(c)
	-- 将卡号22812963（「创世之神 狄特罗诺米安」）加入本卡的代码列表，用于效果内判断该卡名是否存在。
	aux.AddCodeList(c,22812963)
	-- ①：自己场上有原本攻击力或原本守备力是2500的怪兽存在的场合，以对方场上1张卡为对象才能发动（自己场上有「创世之神 狄特罗诺米安」存在的场合，这个效果的对象可以变成2张）。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从手卡把1只攻击力或守备力是2500的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果②的发动条件：这张卡送去墓地的回合不能发动（即必须不是本回合被送去墓地的卡才能发动）。
	e2:SetCondition(aux.exccon)
	-- 设置效果②的发动代价：将墓地里的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 定义筛选条件：表侧表示且原本攻击力或原本守备力为2500的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and (c:GetBaseAttack()==2500 or c:GetBaseDefense()==2500)
end
-- 效果①的发动条件判定：自己场上是否存在原本攻击力或守备力为2500的表侧表示怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上（主要怪兽区）是否存在至少1只满足s.cfilter的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动目标处理：决定可选对象数（1或2），选择对方场上能除外的卡为对象，并设置除外操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=1
	-- 若自己场上有表侧表示的「创世之神 狄特罗诺米安」，则本效果可选对象数变为2张。
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,22812963) then ct=2 end
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 发动合法性检查：确认对方场上存在至少1张可以被除外的卡可以作为对象（且能取对象）。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给当前玩家发送选择提示，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1到ct张（ct为1或2）可除外的卡作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：本次效果将除外这些对象卡，对象数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果①处理：取得所有连锁关联的对象卡，将其表侧除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁效果相关联的对象卡组（即发动时选择的对象）。
	local g=Duel.GetTargetsRelateToChain()
	if #g>0 then
		-- 将取得的卡以表侧表示除外，原因为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义效果②的怪兽筛选条件：手卡中的怪兽攻击力或守备力为2500，且可被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return (c:IsAttack(2500) or c:IsDefense(2500)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②发动目标处理：确认主要怪兽区有空位且手卡存在符合条件的怪兽，并设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1只满足s.spfilter的怪兽（攻击力或守备力2500且可特殊召唤）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将从手卡特殊召唤1只怪兽（处理时对象不固定，所以目标为nil）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②处理：再次确认空位后，从手卡选择1只符合条件的怪兽表侧攻击表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时如果主要怪兽区没有空位则结束处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给当前玩家发送选择提示，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足s.spfilter的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到自己的主要怪兽区，表示形式为表侧攻击表示，不检查召唤条件和苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
