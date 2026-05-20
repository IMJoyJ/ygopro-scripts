--クシャトリラ・アクストラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「俱舍怒威族」超量怪兽被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·场上选1只「维萨斯-斯塔弗罗斯特」除外，从额外卡组把1只「维舍斯-阿修特罗德」无视召唤条件特殊召唤。
-- ②：这张卡被除外的场合，以除外的1只自己的「维萨斯-斯塔弗罗斯特」为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册该卡的效果①（被破坏时发动）和效果②（被除外时发动）。
function s.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」的卡片密码注册到该卡的关联卡片列表中。
	aux.AddCodeList(c,56099748)
	-- ①：自己场上的表侧表示的「俱舍怒威族」超量怪兽被战斗·效果破坏的场合才能发动。从自己的手卡·卡组·场上选1只「维萨斯-斯塔弗罗斯特」除外，从额外卡组把1只「维舍斯-阿修特罗德」无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以除外的1只自己的「维萨斯-斯塔弗罗斯特」为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的「俱舍怒威族」超量怪兽因战斗或效果被破坏。
function s.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousTypeOnField()&TYPE_XYZ~=0
		and c:IsPreviousSetCard(0x189)
end
-- 效果①的发动条件：检查被破坏的卡中是否存在满足条件的「俱舍怒威族」超量怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤条件：手卡·卡组·场上的「维萨斯-斯塔弗罗斯特」，且额外卡组有可以特殊召唤的「维舍斯-阿修特罗德」。
function s.rmfilter(c,e,tp)
	return c:IsCode(56099748) and c:IsAbleToRemove()
		-- 检查额外卡组是否存在可以特殊召唤的「维舍斯-阿修特罗德」（需考虑除外该卡后释放的额外怪兽区域）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 过滤条件：额外卡组的「维舍斯-阿修特罗德」，且满足无视召唤条件特殊召唤的条件。
function s.spfilter(c,e,tp,rc)
	-- 检查卡片是否为「维舍斯-阿修特罗德」，是否能无视召唤条件特殊召唤，且额外怪兽区域有空位。
	return c:IsCode(65815684) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
end
-- 效果①的发动准备：检查是否有可除外的卡，并设置特殊召唤和除外的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡·卡组·场上是否存在满足除外条件的「维萨斯-斯塔弗罗斯特」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置除外的操作信息：从手卡·卡组·场上除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
end
-- 效果①的效果处理：除外1只「维萨斯-斯塔弗罗斯特」，并特殊召唤1只「维舍斯-阿修特罗德」。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡·卡组·场上选择1只「维萨斯-斯塔弗罗斯特」。
	local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 如果成功选择并表侧表示除外了该怪兽。
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只「维舍斯-阿修特罗德」。
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
		if #sg>0 then
			-- 将选择的怪兽无视召唤条件表侧表示特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：除外的表侧表示的「维萨斯-斯塔弗罗斯特」怪兽，且能加入手卡。
function s.thfilter(c)
	return c:IsCode(56099748) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsAbleToHand()
end
-- 效果②的发动准备：选择除外的1只「维萨斯-斯塔弗罗斯特」为对象，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and s.thfilter(chkc) end
	-- 检查除外区是否存在可以加入手卡的「维萨斯-斯塔弗罗斯特」。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择除外的1只「维萨斯-斯塔弗罗斯特」作为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置加入手卡的操作信息：将选中的对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该卡因效果加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
