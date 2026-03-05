--エヴォルダー・リオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「通向进化的吊桥」或「进化的特异点」在自己场上盖放。
-- ②：这张卡是已召唤或者已用炎属性怪兽的效果特殊召唤的场合，自己主要阶段才能发动。从卡组把1只爬虫类族·恐龙族的炎属性怪兽送去墓地。那之后，可以把场上2只怪兽的种族和等级变成和送去墓地的怪兽相同。
local s,id,o=GetID()
-- 初始化效果函数，创建并注册多个效果，包括①②效果的触发条件和处理函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「通向进化的吊桥」或「进化的特异点」在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 记录该卡是否通过炎属性怪兽的效果特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(s.checkop)
	c:RegisterEffect(e3)
	-- ②：这张卡是已召唤或者已用炎属性怪兽的效果特殊召唤的场合，自己主要阶段才能发动。从卡组把1只爬虫类族·恐龙族的炎属性怪兽送去墓地。那之后，可以把场上2只怪兽的种族和等级变成和送去墓地的怪兽相同。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于筛选可以盖放的「通向进化的吊桥」或「进化的特异点」
function s.setfilter(c)
	return c:IsCode(93504463,74100225) and c:IsSSetable()
end
-- 设置①效果的发动条件，检查是否能从卡组选择1张「通向进化的吊桥」或「进化的特异点」
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从卡组选择1张「通向进化的吊桥」或「进化的特异点」
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理函数，选择并盖放1张「通向进化的吊桥」或「进化的特异点」
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	-- 从卡组选择1张「通向进化的吊桥」或「进化的特异点」
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡盖放到场上
		Duel.SSet(tp,g)
	end
end
-- 记录该卡是否通过炎属性怪兽的效果特殊召唤
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	if re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_FIRE) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_TEMP_REMOVE,0,1)
	end
end
-- ②效果的发动条件，判断该卡是否为正常召唤或通过炎属性怪兽的效果特殊召唤
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetFlagEffect(id)>0
end
-- 过滤函数，用于筛选可以送去墓地的爬虫类族·恐龙族的炎属性怪兽
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_REPTILE+RACE_DINOSAUR)
		and c:IsAbleToGrave()
end
-- 设置②效果的发动条件，检查是否能从卡组选择1只符合条件的怪兽
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能从卡组选择1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置②效果的处理信息，指定将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选场上可以改变种族和等级的怪兽
function s.filter(c,race,lv)
	return c:IsFaceup() and not c:IsType(TYPE_LINK+TYPE_XYZ) and (not c:IsRace(race) or not c:IsLevel(lv))
end
-- ②效果的处理函数，选择并送去墓地1只符合条件的怪兽，然后改变场上2只怪兽的种族和等级
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组选择1只符合条件的怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		-- 将选中的怪兽送去墓地并确认其在墓地
		if Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
			local race,lv=tc:GetRace(),tc:GetLevel()
			if race==0 or lv==0 then return end
			-- 获取场上满足条件的怪兽组，用于后续改变种族和等级
			local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,race,lv)
			-- 判断场上是否有至少2只符合条件的怪兽并询问是否发动效果
			if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 提示玩家选择要改变种族和等级的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				local sg=g:Select(tp,2,2,nil)
				local c=e:GetHandler()
				-- 显示选中的怪兽被选为对象
				Duel.HintSelection(sg)
				-- 中断当前效果，使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 遍历选中的怪兽，为每只怪兽添加改变种族和等级的效果
				for sc in aux.Next(sg) do
					-- 为选中的怪兽添加改变种族的效果
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CHANGE_RACE)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetValue(race)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					sc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_CHANGE_LEVEL)
					e2:SetValue(lv)
					sc:RegisterEffect(e2)
				end
			end
		end
	end
end
