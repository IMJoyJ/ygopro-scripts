--刻まれし魔ラクリモーサ
-- 效果：
-- 恶魔族·光属性怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以自己的墓地·除外状态的1只恶魔族·光属性怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降600。
-- ③：这张卡被送去墓地的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组才能发动。给与对方1200伤害。
local s,id,o=GetID()
-- 注册该卡的召唤限制与融合素材条件（2只光属性·恶魔族怪兽），并依次创建注册①效果（融合召唤时回收/特召）、②效果（降低对方怪兽攻击）、③效果（送墓时给予伤害）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：使用2只满足s.ffilter条件的光属性·恶魔族怪兽作为融合素材。
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	-- ①：这张卡融合召唤的场合，以自己的墓地·除外状态的1只恶魔族·光属性怪兽为对象才能发动。那只怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡或特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降600。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-600)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，从自己墓地让1只其他的恶魔族·光属性怪兽回到卡组·额外卡组才能发动。给与对方1200伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"给予伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
-- 定义融合素材过滤条件：怪兽需为光属性且恶魔族，可作为融合素材。
function s.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end
-- ①效果的发动条件：这张卡是以融合召唤方式特殊召唤成功时。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 定义①效果可选择的对象：自己墓地或除外状态的光属性·恶魔族怪兽，且能够加入手卡，或在有可用怪兽区空格时能够特殊召唤。
function s.filter(c,e,tp,ft)
	return c:IsFaceupEx() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToHand() or ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP))
end
-- ①效果的取对象处理：从自己墓地或除外状态选择1只符合条件的恶魔族·光属性怪兽作为对象；若对象在墓地，则额外将效果类别标记为包含墓地动作/墓地特殊召唤，以正确响应相关时点。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的主要怪兽区空格数，用于判断是否能够特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp,ft) end
	-- 发动检查：确认自己墓地或除外状态存在至少1只满足s.filter条件的怪兽可作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,ft) end
	-- 向玩家显示“请选择效果的对象”的提示信息，用于选择卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己墓地或除外状态选择1只符合条件的怪兽，设定为效果对象并记录为连锁对象。
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,ft):GetFirst()
	if tc:IsLocation(LOCATION_GRAVE) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	end
end
-- ①效果处理：若对象仍与效果关联，先检查是否受王家长眠之谷影响；若受影响则无效。否则在满足特殊召唤条件且（对象不能加入手卡或玩家选择特殊召唤）时，将对象特殊召唤；否则将对象加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 若对象受“王家长眠之谷”影响且当前连锁可被无效，则自动无效并终止该效果的后续处理。
		if aux.NecroValleyNegateCheck(tc) then return end
		-- 再次过滤：若对象受王家长眠之谷影响，则终止处理。
		if not aux.NecroValleyFilter()(tc) then return end
		-- 判断能否特殊召唤：自己场上有可用怪兽区空格，且对象可以被特殊召唤（表侧表示），满足才进入特召分支。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			-- 若对象不能加入手卡则无条件选择特召；否则弹出选项让玩家选择：0为加入手卡，1为特殊召唤；仅当选择特殊召唤时进入特召分支。
			and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
			-- 将对象怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件、苏生限制）。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将对象怪兽加入其持有者的手卡（效果处理）。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 定义③效果费用过滤条件：自己墓地中除自身以外且为光属性·恶魔族的怪兽，并且可以作为费用返回卡组或额外卡组。
function s.costfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeckOrExtraAsCost()
end
-- ③效果的发动代价处理：从自己墓地选择1只符合条件的其他光属性·恶魔族怪兽，返回持有者卡组/额外卡组并洗切，作为发动代价。
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动前检查：自己墓地是否存在至少1只满足costfilter条件的其他光属性·恶魔族怪兽可作为费用。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 向玩家显示“请选择要返回卡组的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地中选择1只除自身以外的光属性·恶魔族怪兽作为返回卡组的费用卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 显示所选费用卡的选中动画，并记录为已选择对象。
	Duel.HintSelection(g)
	-- 将选择的费用卡返回其持有者的卡组，并洗切卡组（作为发动代价）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ③效果的目标设定：指定对方为受到伤害的玩家，伤害值为1200，并登记伤害效果的操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的目标参数设置为1200，即伤害数值。
	Duel.SetTargetParam(1200)
	-- 登记操作信息：将对对方造成1200点效果伤害（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
-- ③效果处理：从连锁中读取目标玩家和伤害值，并给予对方效果伤害。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予目标玩家指定数值的效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
