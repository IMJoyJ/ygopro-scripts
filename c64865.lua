--サイバース・コード・マジシャン
-- 效果：
-- 「电脑网仪式」降临
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把自己场上的连接怪兽作为电子界族连接怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
-- ②：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把1只电子界族怪兽送去墓地。仪式召唤的这张卡被送去墓地的场合，也能不从卡组送去墓地特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 在卡片效果初始化函数中，设定其仪式召唤所必须的仪式复活限制，注册手牌连接素材的永续效果e1，以及从手牌或场上送去墓地时诱发的选发效果e2。
function s.initial_effect(c)
	-- 在卡片信息中记录该卡记载了「电脑网仪式」（卡号：34767865）的卡名。
	aux.AddCodeList(c,34767865)
	c:EnableReviveLimit()
	-- ①：把自己场上的连接怪兽作为电子界族连接怪兽的连接素材的场合，手卡的这张卡也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·场上送去墓地的场合才能发动。从卡组把1只电子界族怪兽送去墓地。仪式召唤的这张卡被送去墓地的场合，也能不从卡组送去墓地特殊召唤。这个回合，自己不是电子界族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 过滤函数：用于筛选自己场上的连接怪兽，作手卡素材的辅助判定。
function s.mfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_LINK) and c:IsControler(tp)
end
-- 过滤函数：筛选手牌中该卡自身，避免重复作为额外连接素材被检测。
function s.exmfilter(c)
	return c:IsLocation(LOCATION_HAND) and c:IsCode(id)
end
-- 设定手牌作为素材的适用条件：连接怪兽必须是电子界族，且自己场上有至少1只连接怪兽被用作素材，并且手牌中没有其他该卡本身被用作素材。
function s.matval(e,lc,mg,c,tp)
	if not lc:IsRace(RACE_CYBERSE) then return false,nil end
	return true,not mg or mg:IsExists(s.mfilter,1,nil,tp) and not mg:IsExists(s.exmfilter,1,nil)
end
-- 诱发效果的触发条件函数：检查该卡是否是从场上或手牌送去墓地，并检查其送墓前是否属于仪式召唤登场状态，以决定后续效果是否能选择特殊召唤。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	e:SetLabel(0)
	if c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND) then
		if c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL) then
			e:SetLabel(1)
			c:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"仪式召唤的这张卡被送去墓地"
		end
		return true
	else
		return false
	end
end
-- 过滤函数：筛选卡组中的电子界族怪兽，根据是否满足特殊召唤的标记（label > 0）和场上空格数，判定该怪兽是否能送去墓地或特殊召唤。
function s.tgfilter(c,e,tp,label)
	-- 获取自己场上怪兽区域的空余格子数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsRace(RACE_CYBERSE) and (c:IsAbleToGrave()
		or label>0 and ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
-- 诱发效果的发动目标校验与分类设置函数，根据该卡是否由场上仪式召唤送墓，设定对应的效果分类（仅送墓，或送墓+特殊召唤）。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabel()
	-- 校验效果发动的可行性：检查卡组中是否存在符合条件的电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp,label) end
	if label>0 then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
		-- 设置连锁处理的操作信息，声明本次效果会从卡组将1张卡送去墓地。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- 诱发效果的处理函数：让玩家从卡组选择1只电子界族怪兽，并根据发动的条件分支由玩家选择将其送去墓地或直接特殊召唤，最后为玩家施加本回合不能特殊召唤非电子界族怪兽的限制。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，指示选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中筛选1只符合条件的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,e:GetLabel())
	-- 获取自己怪兽区域的空余格子数量，以作特召格子校验。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		local spchk=e:GetLabel()>0 and ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若该卡可以送墓，且（不满足特召条件 或 玩家选择“送去墓地”选项时），进入将怪兽送去墓地的处理分支。
		if tc:IsAbleToGrave() and (not spchk or Duel.SelectOption(tp,1191,1152)==0) then
			-- 将选择的卡片因效果送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		elseif spchk then
			-- 将符合条件的电子界族怪兽以表侧表示特殊召唤。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册“不能特殊召唤非电子界族怪兽”的誓约限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制效果的靶点函数，过滤出所有非电子界族的怪兽，使其不能进行特殊召唤。
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
