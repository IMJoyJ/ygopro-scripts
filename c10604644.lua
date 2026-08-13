--セリオンズ“キング”レギュラス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或机械族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备魔法卡使用给这张卡装备。
-- ②：对方把效果发动时，从自己的手卡·场上（表侧表示）把1张「兽带斗神」怪兽卡送去墓地才能发动。那个效果无效。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
local s,id,o=GetID()
-- 创建并注册本卡的全部效果：e1为①起动效果（从手卡特召并装备墓地怪兽），e2为②诱发即时效果（无效对方效果），e3为GRANT效果使装备怪兽获得e2，e4为装备时提升装备怪兽700攻击力。
function c10604644.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或机械族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10604644,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,10604644)
	e1:SetTarget(c10604644.sptg)
	e1:SetOperation(c10604644.spop)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时，从自己的手卡·场上（表侧表示）把1张「兽带斗神」怪兽卡送去墓地才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10604644,1))  --"对方效果无效（兽带斗神“王者”轩辕十四）"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10604644+o)
	e2:SetCondition(c10604644.discon)
	e2:SetCost(c10604644.discost)
	e2:SetTarget(c10604644.distg)
	e2:SetOperation(c10604644.disop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c10604644.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c10604644.atkcon)
	c:RegisterEffect(e4)
end
-- 定义①效果的墓地对象过滤条件：满足「兽带斗神」字段或机械族、是怪兽卡，且自己场上不存在同名卡限制（CheckUniqueOnField）。
function c10604644.eqfilter(c,tp)
	return (c:IsRace(RACE_MACHINE) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的发动判定与取对象：先检查主怪兽区和魔陷区有空位、墓地存在符合条件的对象、这张卡可特殊召唤；在指定对象时确认对象位于墓地且满足条件。
function c10604644.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c10604644.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 发动时检查：自己主怪兽区和魔陷区都有可用空格，确保能特殊召唤这张卡并装备墓地怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在至少1只满足eqfilter条件的怪兽，可作为效果对象。
		and Duel.IsExistingTarget(c10604644.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向操作者显示选择提示：“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地选择1只满足条件的怪兽作为效果对象（取对象），并自动记录为当前连锁对象。
	local sg=Duel.SelectTarget(tp,c10604644.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：对象卡将离开墓地，以便「王家长眠之谷」等效果能正确连锁/适用。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息：这张卡将被特殊召唤，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联且怪兽区有空位，将其表侧攻击表示特殊召唤；成功后取对象怪兽，若对象仍关联且魔陷区有空位，则将对象作为装备卡装备给这张卡，并为对象附加只能装备给这张卡的限制效果。
function c10604644.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否仍在手牌且与效果关联，以及主怪兽区是否有空位可用于特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡以表侧表示特殊召唤到自己场上；若成功（返回值≠0）则继续处理装备。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 取得发动时选择的对象怪兽（墓地那只）。
		local tc=Duel.GetFirstTarget()
		-- 确认对象怪兽仍然与效果关联（没有离场或失效），且魔陷区有空位可放置装备卡。
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将对象怪兽作为装备魔法卡装备给这张卡（up=false表示保持原表示形式）。
			Duel.Equip(tp,tc,c,false)
			-- “作为对象的怪兽当作装备魔法卡使用给这张卡装备。”——此处为装备卡附加装备对象限制，确保其只能装备给本卡。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c10604644.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制：只有当装备对象是效果的所有者（本卡）时才允许装备。
function c10604644.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②的发动条件：对方玩家发动效果（连锁发生且发动者不是自己）。
function c10604644.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
-- 定义②的COST可送墓的卡：卡名含有「兽带斗神」字段、原本类型为怪兽卡，且可以作为COST送去墓地。
function c10604644.cfilter(c)
	return c:IsSetCard(0x179) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- ②的COST处理：从手卡或场上选择1张满足cfilter的「兽带斗神」怪兽卡送去墓地。
function c10604644.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查COST是否满足：手卡或场上是否存在至少1张可送去墓地的「兽带斗神」怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c10604644.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 显示选择提示：“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡或场上选择1张符合条件的「兽带斗神」怪兽卡作为COST。
	local g=Duel.SelectMatchingCard(tp,c10604644.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地，作为发动②的COST。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②的发动目标阶段：无特定取对象，直接告知双方将无效对方发动的效果，并设置操作信息为无效该效果。
function c10604644.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对手提示：对方选择了「对方效果无效（兽带斗神“王者”轩辕十四）」，即宣告发动无效效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次连锁将无效对方发动的那个效果（CATEGORY_DISABLE）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ②效果处理：直接无效当前连锁中对方发动的效果。
function c10604644.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方发动的那个效果无效。
	Duel.NegateEffect(ev)
end
-- GRANT效果的适用对象：场上的「兽带斗神」怪兽，且其装备区包含这张卡（e:GetHandler()）时，获得本卡的②效果（e2）。
function c10604644.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- e4（攻击力上升）的适用条件：这张卡的装备目标存在且为「兽带斗神」怪兽。
function c10604644.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
