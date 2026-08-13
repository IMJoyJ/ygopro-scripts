--魔界発現世行きデスガイド
-- 效果：
-- ①：这张卡召唤时才能发动。从手卡·卡组把1只恶魔族·3星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，不能作为同调素材。
function c10802915.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从手卡·卡组把1只恶魔族·3星怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，不能作为同调素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10802915,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c10802915.sptg)
	e2:SetOperation(c10802915.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选“手卡·卡组中等级为3、种族为恶魔族、且可以被特殊召唤的怪兽”，作为后续检索和特殊召唤的判断条件。
function c10802915.filter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 诱发效果的发动条件判断：在发动时确认自己场上主要怪兽区域是否有空位，并且手卡·卡组中是否存在满足条件的1只恶魔族·3星怪兽；满足则效果可发动。
function c10802915.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区域是否存在可用空位，保证特殊召唤有格子可出。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·卡组中是否存在至少1只符合filter条件的怪兽（供特殊召唤选用）。
		and Duel.IsExistingMatchingCard(c10802915.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将本次效果处理信息登记为“特殊召唤”1只怪兽，素材来源为手卡·卡组，用于连锁处理时让系统正确判定相关效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理时的操作：从手卡·卡组挑选1只符合条件的恶魔族·3星怪兽进行特殊召唤，并给那只怪兽附加“效果无效化”和“不能作为同调素材”的状态。
function c10802915.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认主要怪兽区域仍有空位；若已无空位则中止本次特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示，并缓存选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作玩家从手卡·卡组中选择1只满足filter条件的怪兽，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c10802915.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽以表侧表示（正面表示）进行特殊召唤的分步处理，并判断该步是否成功；成功后继续为其附加无效化和不能作为同调素材的效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 不能作为同调素材
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
	end
	-- 完成分步特殊召唤，使之前通过SpecialSummonStep处理的怪兽正式特殊召唤成功，并触发召唤成功的相关时点。
	Duel.SpecialSummonComplete()
end
