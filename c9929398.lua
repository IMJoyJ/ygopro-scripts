--BF－朧影のゴウフウ
-- 效果：
-- 这张卡不能通常召唤。自己场上没有怪兽存在的场合可以特殊召唤。
-- ①：这张卡从手卡的特殊召唤成功时才能发动。在自己场上把2只「胧影衍生物」（鸟兽族·暗·1星·攻/守0）特殊召唤。这衍生物不能解放，不能作为同调素材。
-- ②：把这张卡和除调整以外的怪兽1只以上从自己场上除外，以持有和那个等级合计相同等级的自己墓地1只「黑羽」同调怪兽为对象才能发动。那只怪兽当作调整使用特殊召唤。
function c9929398.initial_effect(c)
	c:EnableReviveLimit()
	-- 『这张卡不能通常召唤。自己场上没有怪兽存在的场合可以特殊召唤。』对应的特殊召唤规则效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c9929398.spcon)
	c:RegisterEffect(e1)
	-- ①：这张卡从手卡的特殊召唤成功时才能发动。在自己场上把2只「胧影衍生物」（鸟兽族·暗·1星·攻/守0）特殊召唤。这衍生物不能解放，不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9929398,0))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c9929398.tkncon)
	e2:SetTarget(c9929398.tkntg)
	e2:SetOperation(c9929398.tknop)
	c:RegisterEffect(e2)
	-- ②：把这张卡和除调整以外的怪兽1只以上从自己场上除外，以持有和那个等级合计相同等级的自己墓地1只「黑羽」同调怪兽为对象才能发动。那只怪兽当作调整使用特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9929398,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c9929398.target)
	e3:SetOperation(c9929398.operation)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则效果的条件函数：若c为空则规则适用；否则需要己方场上没有怪兽且主要怪兽区有空位，才允许从手牌特殊召唤此卡。
function c9929398.spcon(e,c)
	if c==nil then return true end
	-- 判定自己场上（主要怪兽区＋额外怪兽区）不存在任何怪兽。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 判定自己的主要怪兽区有可用的空格，确保此卡能特殊召唤到场上。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ①效果的诱发条件：此卡从手牌特殊召唤成功时才能发动。
function c9929398.tkncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ①效果的发动时点合法性检查：场上没有【青眼精灵龙】的‘禁止二只以上同时特殊召唤’干扰，且自己有至少2个可用主要怪兽区空格，且能够特殊召唤2只「胧影衍生物」。
function c9929398.tkntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 自己的主要怪兽区剩余空格数必须大于1，才能同时特殊召唤2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家能否特殊召唤符合「胧影衍生物」参数的衍生物：卡号9929399、token怪兽、1星、鸟兽族、暗属性、攻/守0。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,9929399,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_WINDBEAST,ATTRIBUTE_DARK) end
	-- 向系统登记本效果将产生2只衍生物，供场合/时点类效果正确连锁。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 向系统登记本效果将特殊召唤2只衍生物，供场合/时点类效果正确连锁。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果处理：若仍无【青眼精灵龙】限制且有足够空格且可特召衍生物，依次生成2只「胧影衍生物」并表侧特殊召唤；同时为每只衍生物附加不能作为解放（上级/非上级召唤）及不能作为同调素材的限制；最后完成特殊召唤。
function c9929398.tknop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时再次确认主要怪兽区仍至少有2个空格，防止被连锁导致无法特召。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 效果处理时再次确认玩家仍可特殊召唤符合参数的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,9929399,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_WINDBEAST,ATTRIBUTE_DARK) then
		for i=1,2 do
			-- 生成1只「胧影衍生物」token（卡号9929399）。
			local token=Duel.CreateToken(tp,9929399)
			-- 将生成的衍生物以表侧表示加入特殊召唤处理流程（暂不实际出场）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 『这衍生物不能解放，不能作为同调素材。』以及『②：把这张卡和除调整以外的怪兽1只以上从自己场上除外，以持有和那个等级合计相同等级的自己墓地1只「黑羽」同调怪兽为对象才能发动。那只怪兽当作调整使用特殊召唤。』
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
			token:RegisterEffect(e3,true)
		end
		-- 完成衍生物特殊召唤流程，使全部衍生物同时正式登场。
		Duel.SpecialSummonComplete()
	end
end
-- ②代价筛选：自己场上表侧表示、等级大于0、不是调整怪兽且可作为除外费用的怪兽。
function c9929398.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost() and c:IsLevelAbove(0)
end
-- 判定候选「黑羽」同调怪兽是否可被特殊召唤，以及其等级与这张卡的等级之差是否能通过除外1只以上非调整怪兽来凑出相应合计等级。
function c9929398.spfilter(c,e,tp,ct)
	local rlv=c:GetLevel()-e:GetHandler():GetLevel()
	if rlv<1 then return false end
	-- 获取自己场上除这张卡外可作为除外费用的非调整怪兽集合。
	local rg=Duel.GetMatchingGroup(c9929398.cfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	return c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and rg:CheckWithSumEqual(Card.GetLevel,rlv,ct,63)
end
-- 取对象判定：对象必须是自己墓地的「黑羽」同调怪兽，等级为指定数值，且能够被特殊召唤。
function c9929398.chkcfilter(c,e,tp,lv)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x33)
		and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动条件检查：此卡可作为除外费用、且有符合条件的墓地「黑羽」同调怪兽可选；同时记录当前场上空格数的负值供代价筛选使用。
function c9929398.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 将当前可用主要怪兽区空格数取负，作为后续选择除外怪兽数量的下限宽松值（使得等级合计筛选不受空格数限制）。
	local ct=-Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return c9929398.chkcfilter(chkc,e,tp,e:GetLabel()) end
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 确认墓地存在至少1只满足spfilter条件的「黑羽」同调怪兽可以作为对象。
		and Duel.IsExistingTarget(c9929398.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ct) end
	-- 弹出选择提示，让玩家从墓地选择要特殊召唤的「黑羽」同调怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1只符合条件的墓地「黑羽」同调怪兽，并将其设为效果处理的对象。
	local g=Duel.SelectTarget(tp,c9929398.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ct)
	local rlv=g:GetFirst():GetLevel()-e:GetHandler():GetLevel()
	-- 再次取得可除外的非调整怪兽集合，用于下一步选择除外代价。
	local rg=Duel.GetMatchingGroup(c9929398.cfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 弹出选择提示，让玩家选择要除外的场上怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g2=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,ct,63)
	g2:AddCard(e:GetHandler())
	-- 将玩家选中的怪兽与这张卡一起以表侧表示除外，作为发动②效果的费用。
	Duel.Remove(g2,POS_FACEUP,REASON_COST)
	-- 登记本效果将特殊召唤对象怪兽，供连锁相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- ②效果处理：取得对象怪兽，若仍可特殊召唤则将其特殊召唤，并给它附加‘当作调整使用’的永续效果；最后完成特殊召唤。
function c9929398.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽仍与效果相关且能够特殊召唤时，将其加入特殊召唤流程。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 那只怪兽当作调整使用特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
	-- 完成目标怪兽的特殊召唤流程，使墓地选出的「黑羽」同调怪兽正式出场。
	Duel.SpecialSummonComplete()
end
