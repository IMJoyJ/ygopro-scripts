--流星竜メテオ・ブラック・ドラゴン
-- 效果：
-- 7星「真红眼」怪兽＋6星龙族怪兽
-- ①：这张卡融合召唤的场合才能发动。从手卡·卡组把1只「真红眼」怪兽送去墓地，给与对方那只怪兽的攻击力一半数值的伤害。
-- ②：这张卡从怪兽区域送去墓地的场合，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c30086349.initial_effect(c)
	-- 为这张卡添加融合召唤手续：融合素材为1只7星「真红眼」怪兽和1只6星龙族怪兽
	aux.AddFusionProcFun2(c,c30086349.mfilter1,c30086349.mfilter2,true)
	c:EnableReviveLimit()
	-- 对应①：这张卡融合召唤的场合才能发动。从手卡·卡组把1只「真红眼」怪兽送去墓地，给与对方那只怪兽的攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30086349,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c30086349.damcon)
	e1:SetTarget(c30086349.damtg)
	e1:SetOperation(c30086349.damop)
	c:RegisterEffect(e1)
	-- 对应②：这张卡从怪兽区域送去墓地的场合，以自己墓地1只通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30086349,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c30086349.spcon)
	e2:SetTarget(c30086349.sptg)
	e2:SetOperation(c30086349.spop)
	c:RegisterEffect(e2)
end
c30086349.material_setcode=0x3b
-- 融合素材过滤器1：要求是「真红眼」怪兽（作为融合素材时满足真红眼字段）且等级为7。
function c30086349.mfilter1(c)
	return c:IsFusionSetCard(0x3b) and c:IsLevel(7)
end
-- 融合素材过滤器2：要求是龙族怪兽且等级为6。
function c30086349.mfilter2(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(6)
end
-- 效果①的发动条件：这张卡以融合召唤方式特殊召唤成功。
function c30086349.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①需要送去墓地的卡的条件：是「真红眼」怪兽、原本攻击力大于0、且可以被送去墓地。
function c30086349.damfilter(c)
	return c:IsFusionSetCard(0x3b) and c:GetBaseAttack()>0 and c:IsAbleToGrave()
end
-- 效果①的发动目标处理：若已确认存在可送去墓地的「真红眼」怪兽，则设置连锁信息为造成伤害（对象为对方）。
function c30086349.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动时的合法性检查：自己手卡·卡组中是否存在至少1张符合条件的「真红眼」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30086349.damfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：本效果包含伤害分类，伤害对象为对方玩家（1-tp），具体伤害数值在处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果①处理：从手卡·卡组选择1只符合条件的「真红眼」怪兽送去墓地；若成功送去墓地且该卡在墓地，则给对方造成其原本攻击力一半数值的伤害。
function c30086349.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡（向选择缓存写入“请选择要送去墓地的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从玩家自己的手卡·卡组中选择1张满足damfilter的「真红眼」怪兽。
	local g=Duel.SelectMatchingCard(tp,c30086349.damfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若选择成功且将该卡送去墓地成功、且该卡仍在墓地，则执行后续伤害处理（防止因其他效果导致卡不在墓地时仍伤害）。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 给对方造成所送去怪兽原本攻击力一半数值的伤害，伤害原因为效果。
		Duel.Damage(1-tp,math.floor(g:GetFirst():GetBaseAttack()/2),REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡从怪兽区域被送去墓地（之前所在位置是主要怪兽区）。
function c30086349.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 效果②的对象筛选：自己墓地的通常怪兽，且可以被当前效果特殊召唤。
function c30086349.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动目标处理：检查自己主要怪兽区有空位，且墓地存在符合条件的通常怪兽；若满足则选择其中1只为对象。
function c30086349.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c30086349.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有可用空格，确保特殊召唤可以进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只可以成为对象的通常怪兽。
		and Duel.IsExistingTarget(c30086349.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡（向选择缓存写入“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的通常怪兽作为效果对象（并登记为连锁对象）。
	local g=Duel.SelectTarget(tp,c30086349.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：本效果包含特殊召唤，将对象g（1张卡）特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②处理：若对象卡仍与效果有联系，则将其特殊召唤到自己场上（表侧表示）。
function c30086349.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得该效果选择的对象卡（因为只取了1个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
