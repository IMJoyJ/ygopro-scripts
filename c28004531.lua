--空牙団の積荷 レクス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「空牙团」魔法·陷阱卡加入手卡。
-- ②：自己·对方的主要阶段，自己场上有「空牙团」怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「空牙团」卡为对象才能发动。那张卡加入手卡。作为对象的卡是怪兽的场合，也能不加入手卡特殊召唤。
local s,id,o=GetID()
-- 定义该卡的效果注册函数：创建并注册①的召唤·特殊召唤时检索「空牙团」魔法·陷阱卡的效果，以及②的在主要阶段从墓地除外自身并取对象回收/特殊召唤「空牙团」卡的效果；两个效果各有1回合1次的次数限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「空牙团」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己·对方的主要阶段，自己场上有「空牙团」怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「空牙团」卡为对象才能发动。那张卡加入手卡。作为对象的卡是怪兽的场合，也能不加入手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	-- 设置②效果发动时需将墓地中的这张卡除外作为代价。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 筛选条件：卡名含有「空牙团」字段的魔法·陷阱卡，并且可以被加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x114) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件检测与操作信息设定：检查卡组中存在满足条件的「空牙团」魔法·陷阱卡；若存在，则设置处理时从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查时，检测我方卡组是否存在至少1张满足s.thfilter的「空牙团」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定操作信息：本效果属于从卡组检索加入手卡的效果，预计把1张卡加入手卡（目标在处理时选择，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张「空牙团」魔法·陷阱卡加入手牌，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组筛选符合条件的「空牙团」魔法·陷阱卡，选择1张。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 筛选条件：表侧表示且含有「空牙团」字段的怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- ②效果的发动条件：当前为主要阶段（M1或M2），且自己场上有表侧表示的「空牙团」怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 返回是否为主要阶段（M1/M2）且自己场上有表侧「空牙团」怪兽存在。
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 用于筛选墓地中可作为对象的「空牙团」卡：若为怪兽，则要求能加入手牌，或在有可用怪兽区的情况下能被特殊召唤；若不是怪兽，则要求能加入手牌。
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x114) then return false end
	-- 检查我方场上是否有可用的主要怪兽区空格。
	local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if c:IsType(TYPE_MONSTER) then
		return c:IsAbleToHand() or sp and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else return c:IsAbleToHand() end
end
-- ②效果的目标选择：从自己墓地选择1张「空牙团」卡作为对象；若该对象是怪兽，则将效果类别设为可特殊召唤/加入手牌，否则仅设为加入手牌并设置操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检测：自己墓地是否存在1张以上可作为对象的「空牙团」卡（排除当前效果所属的自身）。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 显示‘请选择要加入手牌的卡’的选择提示（此处用于墓地选卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己墓地选择1张符合条件的「空牙团」卡作为效果对象（同时设定为连锁对象）。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TOHAND)
		-- 设置操作信息：本效果处理时将这张对象卡加入持有者手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- ②效果处理：若对象是怪兽，且自己场上有空位、该怪兽可特殊召唤，并且玩家选择特殊召唤（或该卡不能加入手牌时），则将其特殊召唤；否则将其加入手牌。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	if tc:IsType(TYPE_MONSTER)
		-- 确认自己场上有空位且对象怪兽可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若对象可以加入手牌，则弹出选项让玩家选择‘加入手牌’或‘特殊召唤’；若对象不能加入手牌，则直接进入特殊召唤分支。选择第二个选项（特殊召唤）时执行特召。
		and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 将对象卡加入其持有者手牌（效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
