--真紅眼の鋼炎竜
-- 效果：
-- 7星怪兽×2
-- ①：持有超量素材的这张卡不会被效果破坏。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱·怪兽的效果发动给与对方500伤害。
-- ③：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「真红眼」通常怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在对方回合也能发动。
function c44405066.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要用2只7星怪兽作为超量素材叠放来进行超量召唤。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c44405066.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把魔法·陷阱·怪兽的效果发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(c44405066.regop)
	c:RegisterEffect(e2)
	-- 给与对方500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c44405066.damcon)
	e3:SetOperation(c44405066.damop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「真红眼」通常怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44405066,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetCost(c44405066.spcost)
	e4:SetTarget(c44405066.sptg)
	e4:SetOperation(c44405066.spop)
	c:RegisterEffect(e4)
end
-- ①效果的适用条件：判断这张卡是否持有超量素材，持有超量素材时才能被赋予不会被效果破坏的耐性。
function c44405066.indcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 每当有卡的效果发动时，给这张卡注册一个标识（编号44405066），用于标记本连锁中确有发动过效果；该标识会在卡片离场等重置条件或连锁结束时清除。
function c44405066.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(44405066,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- ②效果的处理条件：这张卡持有超量素材，且当前连锁中对方发动了效果（ep≠tp），并且已经记录到效果发动的标识。
function c44405066.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and ep~=tp and c:GetFlagEffect(44405066)~=0
end
-- ②效果的处理：向对方给予500点伤害。
function c44405066.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示这张卡（真红眼钢炎龙）的卡图，用于提示②伤害效果的来源。
	Duel.Hint(HINT_CARD,0,44405066)
	-- 给与对方玩家（1-tp）500点效果伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
-- ③效果的发动代价：从这张卡上取除1个超量素材作为代价。
function c44405066.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果选择对象的筛选条件：自己墓地的「真红眼」系列通常怪兽，且可以被特殊召唤。
function c44405066.spfilter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动与取对象处理：先校验所选对象位于自己墓地且符合条件；发动时确认自己场上有空格且墓地存在至少1只符合条件的「真红眼」通常怪兽。
function c44405066.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44405066.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己场上必须有可用的主要怪兽区空格，才能进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只符合条件的「真红眼」通常怪兽，可以作为③效果的对象。
		and Duel.IsExistingTarget(c44405066.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家从选择框中选择要特殊召唤的卡，显示“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只符合条件的「真红眼」通常怪兽，并将其设为③效果的对象。
	local g=Duel.SelectTarget(tp,c44405066.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本连锁的操作信息：本效果将特殊召唤对象g中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：取得对象怪兽，若该怪兽仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c44405066.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象怪兽（当前连锁的取对象卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽表侧表示特殊召唤到自己（tp）场上；此召唤会照常检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
