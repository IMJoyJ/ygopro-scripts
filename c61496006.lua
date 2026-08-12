--アビス・シャーク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上的怪兽只有水属性怪兽的场合才能发动。这张卡从手卡特殊召唤，从卡组把「渊鲨」以外的1只3～5星的鱼族怪兽加入手卡。这个回合，自己不是水属性怪兽不能特殊召唤，自己的「No.」怪兽用和怪兽的战斗给与对方的战斗伤害只有1次变成2倍。
-- ②：把这张卡在「No.」怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或4星使用。
function c61496006.initial_effect(c)
	-- ①：自己场上的怪兽只有水属性怪兽的场合才能发动。这张卡从手卡特殊召唤，从卡组把「渊鲨」以外的1只3～5星的鱼族怪兽加入手卡。这个回合，自己不是水属性怪兽不能特殊召唤，自己的「No.」怪兽用和怪兽的战斗给与对方的战斗伤害只有1次变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,61496006)
	e1:SetCondition(c61496006.spcon)
	e1:SetTarget(c61496006.sptg)
	e1:SetOperation(c61496006.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡在「No.」怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或4星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c61496006.xyzlv)
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetLabel(4)
	c:RegisterEffect(e3)
end
-- 过滤条件：非水属性怪兽或里侧表示怪兽
function c61496006.spfilter(c)
	return not c:IsAttribute(ATTRIBUTE_WATER) or c:IsFacedown()
end
-- 发动条件：自己场上有怪兽存在，且自己场上的怪兽只有水属性怪兽
function c61496006.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否存在非水属性怪兽或里侧表示怪兽
		and not Duel.IsExistingMatchingCard(c61496006.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：卡组中「渊鲨」以外的3～5星鱼族怪兽
function c61496006.thfilter(c)
	return not c:IsCode(61496006) and c:IsLevelAbove(3) and c:IsLevelBelow(5) and c:IsRace(RACE_FISH) and c:IsAbleToHand()
end
-- 效果发动靶向：检查自身能否特殊召唤，以及卡组中是否存在可检索的鱼族怪兽
function c61496006.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在满足条件的鱼族怪兽
		and Duel.IsExistingMatchingCard(c61496006.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：特殊召唤自身，检索鱼族怪兽，并适用特殊召唤限制与伤害翻倍效果
function c61496006.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡成功特殊召唤，则继续处理检索效果
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取卡组中所有满足条件的鱼族怪兽
		local g=Duel.GetMatchingGroup(c61496006.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			-- 提示玩家选择加入手卡的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				-- 将选中的卡片加入手卡
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
				-- 给对方确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
	-- 这个回合，自己不是水属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c61496006.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：限制玩家只能特殊召唤水属性怪兽
	Duel.RegisterEffect(e1,tp)
	-- 自己的「No.」怪兽用和怪兽的战斗给与对方的战斗伤害只有1次变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c61496006.damcon)
	e2:SetValue(DOUBLE_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果：使「No.」怪兽造成的战斗伤害翻倍
	Duel.RegisterEffect(e2,tp)
end
-- 限制条件：不能特殊召唤非水属性怪兽
function c61496006.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 伤害翻倍效果的适用条件：自己的「No.」怪兽与对方怪兽进行战斗，且本回合该效果尚未适用过
function c61496006.damcon(e)
	local tp=e:GetHandlerPlayer()
	-- 获取自己场上参与战斗的怪兽
	local a,d=Duel.GetBattleMonster(tp)
	if a and d and a:IsControler(tp) and a:IsSetCard(0x48) and a:IsStatus(STATUS_OPPO_BATTLE)
		-- 检查本回合是否尚未适用过该伤害翻倍效果
		and Duel.GetFlagEffect(tp,61496006)==0 then
		-- 注册标记，表示本回合已适用过一次伤害翻倍效果
		Duel.RegisterFlagEffect(tp,61496006,RESET_PHASE+PHASE_END,0,1)
		return true
	end
	return false
end
-- 等级变更效果：作为「No.」怪兽的超量素材时，可以将等级当作3星或4星使用
function c61496006.xyzlv(e,c,rc)
	if rc:IsSetCard(0x48) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
