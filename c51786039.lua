--星雲龍ネビュラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡和手卡1只龙族·8星怪兽给对方观看才能发动。那2只守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是光·暗属性的龙族怪兽不能召唤·特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽加入手卡。
function c51786039.initial_effect(c)
	-- ①：把手卡的这张卡和手卡1只龙族·8星怪兽给对方观看才能发动。那2只守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是光·暗属性的龙族怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51786039,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,51786039)
	e1:SetTarget(c51786039.sptg)
	e1:SetOperation(c51786039.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51786039,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,51786040)
	-- 设置②效果的发动代价为从墓地除外这张卡（作为COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c51786039.thtg)
	e2:SetOperation(c51786039.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：选择手牌中另一只可作为对象的龙族·8星怪兽，要求未公开且能够以表侧守备表示特殊召唤。
function c51786039.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件检查：此卡在手牌未公开、能被表侧守备特殊召唤，自己场上怪兽区空格大于1，且没有青眼精灵龙的‘不能同时特殊召唤2只以上怪兽’限制；然后从手牌选择1只符合条件的龙族·8星怪兽。
function c51786039.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己怪兽区可用空格数大于1，确保发动后能同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not c:IsPublic()
		-- 确认手牌中存在至少1只满足c51786039.spfilter的龙族·8星怪兽（不包含此卡自己），作为展示和特殊召唤的对象。
		and Duel.IsExistingMatchingCard(c51786039.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) end
	-- 向操作玩家显示选择提示：从手牌中选择要给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让操作玩家从手牌选择1只符合条件的龙族·8星怪兽（自身除外），作为‘给对方观看’的对象。
	local g=Duel.SelectMatchingCard(tp,c51786039.spfilter,tp,LOCATION_HAND,0,1,1,c,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽卡展示给对方玩家确认，满足发动条件中的‘给对方观看’。
	Duel.ConfirmCards(1-tp,g)
	-- 给对方观看才能发动。（此段代码让手牌中的这张卡变为公开状态，以实现展示）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 给对方观看才能发动。（此段代码在连锁处理结束后清除公开状态，完成展示后的状态还原）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c51786039.clearop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
	-- 记录当前连锁序号，使辅助效果只在该连锁结束时清除公开状态。
	e2:SetLabel(Duel.GetCurrentChain())
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	tc:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetLabelObject(e3)
	tc:RegisterEffect(e4)
	-- 将选择的龙族·8星怪兽设置为当前连锁的关联对象，供效果处理时获取。
	Duel.SetTargetCard(g)
	-- 设置操作信息：将从手牌特殊召唤2只怪兽，数量为2，供其他卡发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 连锁处理结束的辅助操作：当结束的连锁序号与记录一致时，重置公开效果并移除辅助效果，使手牌中的卡不再公开。
function c51786039.clearop(e,tp,eg,ep,ev,re,r,rp)
	if ev~=e:GetLabel() then return end
	e:GetLabelObject():Reset()
	e:Reset()
end
-- ①效果处理：确认此卡和目标怪仍关联且可特殊召唤后，将两只怪兽以表侧守备表示特殊召唤，并为它们各注册效果无效化（含效果无效化与变里侧重置无效）状态。
function c51786039.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时的第一个目标怪兽，即先前选择的龙族·8星怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
		-- 以表侧守备表示对这张卡进行特殊召唤（特殊召唤过程中的一步）。
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 以表侧守备表示对目标龙族·8星怪兽进行特殊召唤（特殊召唤过程中的一步）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是光·暗属性的龙族怪兽不能召唤·特殊召唤。（此处为召唤成功后的无效化处理，并开始创建后续自肃效果）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		c:RegisterEffect(e2,true)
		local e3=e1:Clone()
		tc:RegisterEffect(e3,true)
		local e4=e2:Clone()
		tc:RegisterEffect(e4,true)
		-- 完成整个特殊召唤过程，宣告两只怪兽同时特殊召唤成功。
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是光·暗属性的龙族怪兽不能召唤·特殊召唤。②：把墓地的这张卡除外，以自己墓地1只光·暗属性的龙族·4星怪兽为对象才能发动。那只怪兽加入手卡。（此处包含自肃效果与②效果的全部实现）
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetTargetRange(1,0)
	e5:SetTarget(c51786039.splimit)
	e5:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘不能特殊召唤光·暗属性以外龙族以外的怪兽’的自肃效果注册给发动玩家，持续到回合结束。
	Duel.RegisterEffect(e5,tp)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	-- 将‘不能通常召唤光·暗属性以外龙族以外的怪兽’的自肃效果注册给发动玩家，持续到回合结束。
	Duel.RegisterEffect(e6,tp)
end
-- 自肃限制的判定：被召唤/特殊召唤的怪兽必须既是龙族又是光属性或暗属性；否则不能召唤/特殊召唤。
function c51786039.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) or not c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ②效果的目标过滤：墓地中满足龙族、4星、光·暗属性且可以被加入手卡的怪兽。
function c51786039.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- ②效果的发动条件检查与对象选择：确认自己墓地存在符合条件的龙族·4星怪兽，并选择1只作为效果对象。
function c51786039.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51786039.thfilter(chkc) end
	-- 发动时检查：自己墓地中是否存在至少1只满足条件的龙族·4星怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51786039.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示选择提示：从墓地选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只符合条件的龙族·4星怪兽，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c51786039.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将所选对象加入手牌（数量1），供其他卡发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若目标怪兽仍与效果关联，则将其从墓地加入持有者手牌。
function c51786039.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽（墓地中选择的龙族·4星怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以‘效果’为原因将对象怪兽送去其持有者的手卡，完成回收。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
