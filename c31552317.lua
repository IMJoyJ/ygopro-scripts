--クリストロン・インクルージョン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把「水晶机巧包体」以外的1张「水晶机巧」卡加入手卡。
-- ②：自己的「水晶机巧」怪兽在1回合各有1次不会被战斗破坏。
-- ③：把墓地的这张卡除外，以自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册本卡的三个效果：e1为发动时检索，e2为永续战斗破坏耐性，e3为墓地除外自身苏生。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把「水晶机巧包体」以外的1张「水晶机巧」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「水晶机巧」怪兽在1回合各有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.indct)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：把墓地的这张卡除外，以自己墓地1只「水晶机巧」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	-- 设置③效果的发动代价：把墓地中的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- ①效果检索的过滤条件：不是「水晶机巧包体」自身、是「水晶机巧」卡、且可以被加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xea) and c:IsAbleToHand()
end
-- ①效果处理：从卡组选取符合条件的最多1张「水晶机巧」卡，经玩家确认后加入手卡，并向对方玩家确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足检索条件的「水晶机巧」卡（不包含「水晶机巧包体」）的集合。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若检索集合非空且玩家确认发动检索，则继续处理加入手卡；否则不进行检索。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 弹出选择提示，要求玩家从选中的卡组卡片中选择1张要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入其持有者的手卡（处理原因记为效果）。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示这次加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- ②效果的保护对象筛选：我方场上的「水晶机巧」怪兽。
function s.indtg(e,c)
	return c:IsSetCard(0xea)
end
-- ②效果的保护次数计算：若破坏原因为战斗破坏，则返回1（本回合可抵挡1次），否则返回0。
function s.indct(e,re,r,rp)
	if r&REASON_BATTLE~=0 then
		return 1
	else return 0 end
end
-- ③效果特殊召唤对象的筛选条件：自己墓地的「水晶机巧」怪兽且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的目标判定：若已经选过对象则验证该对象是否合法；若为发动确认阶段，则检查有怪兽区空位且墓地存在可特殊召唤的对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否存在可用的主要怪兽区空格，作为特殊召唤的发动前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足特殊召唤条件的「水晶机巧」怪兽可作为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 弹出选择提示，要求玩家选择要特殊召唤的「水晶机巧」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件的「水晶机巧」怪兽作为效果对象，并与之建立连锁联系。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息，宣告将进行1只怪兽的特殊召唤，以便相关卡片进行时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：取出对象，确认其仍与效果关联且不受王家长眠之谷等效果影响后，将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果发动时选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果关联且可进行特殊召唤（未被墓地效果无效），则将其表侧表示特殊召唤。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
