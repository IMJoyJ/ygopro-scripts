--同姓同名同盟罷業
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。原本卡名和那只自己怪兽相同的2只怪兽从自己的手卡·卡组·墓地当作装备魔法卡使用给作为对象的怪兽装备。那只怪兽只要这个效果把怪兽2只都装备中，不能攻击，不会被战斗破坏。这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化「同姓同名同盟罢业」的卡片发动效果：1回合只能发动1张，取己方1只表侧怪兽为对象，从手卡·卡组·墓地装备2只同原本卡名怪兽，并适用攻击限制、战破抗性与特召限制。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只表侧表示怪兽为对象才能发动。原本卡名和那只自己怪兽相同的2只怪兽从自己的手卡·卡组·墓地当作装备魔法卡使用给作为对象的怪兽装备。那只怪兽只要这个效果把怪兽2只都装备中，不能攻击，不会被战斗破坏。这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义对象怪兽过滤函数，检查己方怪兽是否为表侧表示，且手卡·卡组·墓地中存在至少2只可作为装备卡使用的原本卡名相同的怪兽。
function s.filter(c,tp)
	local code=c:GetOriginalCodeRule()
	-- 检查怪兽是否为表侧表示且己方手卡·卡组·墓地中存在至少2张满足装备条件的同名怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,2,nil,code,tp)
end
-- 定义装备怪兽过滤函数，检查卡片是否与目标原本卡名相同、为怪兽卡、不违反己方场上唯一性限制且未被禁止使用。
function s.eqfilter(c,code,tp)
	return c:IsOriginalCodeRule(code) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 发动条件检查与对象选择函数：计算除去这张卡自身占位后己方魔法与陷阱区是否至少有2个空位，并检查是否存在合法的己方表侧表示对象怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取自己魔法与陷阱区域当前的可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chk==0 then return ft>1
		-- 检查自己怪兽区是否存在至少1只满足条件且可成为效果对象的怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择要装备对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己怪兽区选择1只满足条件的表侧表示怪兽作为发动对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理主体的装备与赋予效果部分：确认对象有效且魔陷区空位及符合条件怪兽充足后，选2只同名怪兽当作装备卡装备给对象怪兽，并为其注册不能攻击和不被战斗破坏的永续效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCodeRule()
	-- 检查对象怪兽仍与效果关联、处于表侧表示、属于怪兽且自己魔法与陷阱区至少有2个空位。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 检查手卡·卡组·墓地中不受「王家长眠之谷」影响且可装备的原本卡名相同怪兽数量是否大于1。
		and Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,code,tp)>1 then
		-- 向玩家发送选择要当作装备卡装备的卡片提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从手卡·卡组·墓地选择2只不受「王家长眠之谷」影响且满足装备条件的同名怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil,code,tp)
		if #g<2 then return end
		g:KeepAlive()
		local ec=g:GetFirst()
		while ec do
			-- 将选中的怪兽作为己方装备魔法卡装备给对象怪兽，并判断装备是否成功。
			if Duel.Equip(tp,ec,tc) then
				ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0,id)
				-- 当作装备魔法卡使用给作为对象的怪兽装备。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(tc)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
			ec=g:GetNext()
		end
		-- 那只怪兽只要这个效果把怪兽2只都装备中，不能攻击，
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetLabelObject(g)
		e1:SetCondition(s.chkcon)
		tc:RegisterEffect(e1)
		-- 不会被战斗破坏。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetLabelObject(g)
		e2:SetCondition(s.chkcon)
		tc:RegisterEffect(e2)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetOriginalRace())
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 为发动玩家注册直到回合结束阶段为止的特召限制永续效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义特殊召唤限制判定函数：当怪兽的原本种族与作为对象的怪兽原本种族不同（位运算结果为0）时禁止特殊召唤。
function s.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
-- 定义装备卡检查过滤函数，检查卡片是否带有本效果赋予的标记且仍位于对象怪兽的装备卡组中。
function s.chkfilter(c,id,eg)
	return c:GetFlagEffect(id)>0 and eg:IsContains(c)
end
-- 定义2只装备维持条件检查函数：确认对象怪兽当前装备的卡中仍同时包含本效果装备的那2只怪兽。
function s.chkcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	local g=e:GetLabelObject()
	return g:Filter(s.chkfilter,nil,id,eg):GetCount()==2
end
-- 定义装备对象限制函数：限定该装备卡只能装备在最初选择的那个对象怪兽身上。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
