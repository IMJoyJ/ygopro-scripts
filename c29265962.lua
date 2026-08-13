--同姓同名同盟罷業
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。原本卡名和那只自己怪兽相同的2只怪兽从自己的手卡·卡组·墓地当作装备魔法卡使用给作为对象的怪兽装备。那只怪兽只要这个效果把怪兽2只都装备中，不能攻击，不会被战斗破坏。这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
local s,id,o=GetID()
-- 创建并注册本卡的发动效果：作为通常魔法卡可在自由时点发动，取对象，同名卡1回合1次（誓约计数），发动时检查对象，效果处理时进行装备和附加自肃。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 目标怪兽的候选条件：必须为表侧表示，且我方手卡·卡组·墓地中存在至少2只原本卡名与其相同的怪兽可供装备。
function s.filter(c,tp)
	local code=c:GetOriginalCode()
	-- 返回 true 需满足：该怪兽表侧表示，并且可以从我方手卡/卡组/墓地中找到至少2只满足 s.eqfilter 的原本卡名相同的怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,2,nil,code,tp)
end
-- 装备候选怪兽的过滤条件：原本卡名与对象怪兽相同、是怪兽卡、我方场上不存在同名卡的限制（CheckUniqueOnField）且不属于禁止卡。
function s.eqfilter(c,code,tp)
	return c:IsOriginalCodeRule(code) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 发动时目标检查：若为连锁对象（chkc）则验证其位置/控制者/是否符合过滤；同时计算我方魔陷区空格，若本卡未在魔陷区发动则需预留1格；要求发动时魔陷区空位大于1，且场上存在至少1只满足条件的目标怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取我方魔陷区当前可用空格数，用于判断能否容纳后续2张装备魔法卡。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chk==0 then return ft>1
		-- 并且场上至少存在1只满足 s.filter 的怪兽可作为对象，若不存在则不能发动。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家显示“请选择要装备的卡”的提示，用于选择自己场上的表侧表示怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧表示且满足 s.filter 的怪兽，设为该效果的对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理：取得对象，确认对象仍与效果关联且表侧表示，有足够魔陷空格且候选装备怪兽不少于2只；选择2只原本卡名相同的怪兽装备给对象；给装备怪兽追加只能装备给对象的限制；给对象附加在装备2只期间不能攻击、不会被战斗破坏的效果；最后若本卡以魔法卡发动，则给自己附加本回合不能特殊召唤原本种族与对象不同的怪兽的自肃。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽（作为装备对象的自己场上的表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	-- 检查目标怪兽仍与效果关联（未离场）、仍表侧表示且是怪兽，且自己魔陷区空格数大于1，否则不执行装备处理。
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 并且从手卡/卡组/墓地中可选出多于1只（即至少2只）不受王家长眠之谷影响的装备候选怪兽，才能继续处理。
		and Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,code,tp)>1 then
		-- 显示“请选择要装备的卡”的提示，用于从手卡/卡组/墓地选择要装备的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从自己的手卡·卡组·墓地中选择2只满足 s.eqfilter 且不受王家长眠之谷影响的怪兽，作为装备魔法卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil,code,tp)
		if #g<2 then return end
		g:KeepAlive()
		local ec=g:GetFirst()
		while ec do
			-- 将选中的怪兽 ec 尝试作为装备魔法卡装备到目标 tc 上；若装备成功，则继续设置装备限制和标记。
			if Duel.Equip(tp,ec,tc) then
				ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0,id)
				-- 原本卡名和那只自己怪兽相同的2只怪兽从自己的手卡·卡组·墓地当作装备魔法卡使用给作为对象的怪兽装备。
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
		-- 那只怪兽只要这个效果把怪兽2只都装备中，不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetLabelObject(g)
		e1:SetCondition(s.chkcon)
		tc:RegisterEffect(e1)
		-- 那只怪兽只要这个效果把怪兽2只都装备中，不会被战斗破坏。
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
		-- 将自肃效果注册给当前玩家 tp，使其在回合结束前不能特殊召唤原本种族与对象不同的怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 自肃判定函数：若尝试特殊召唤的怪兽原本种族与对象怪兽的原本种族按位与结果为0（完全不同），则禁止该特殊召唤，从而实现‘不是原本种族和对象相同的怪兽不能特殊召唤’。
function s.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
-- 检查怪兽是否带有本次装备设置的标记（flag id），并且属于装备组 eg，用于统计当前仍装备在对象上的本效果装备怪兽。
function s.chkfilter(c,id,eg)
	return c:GetFlagEffect(id)>0 and eg:IsContains(c)
end
-- 作为不能攻击/不会被战斗破坏效果的满足条件：统计对象当前装备区中带有本效果标记且属于本效果所选装备组的怪兽数量，若等于2，则视为‘2只都装备中’，触发相应效果。
function s.chkcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	local g=e:GetLabelObject()
	return g:Filter(s.chkfilter,nil,id,eg):GetCount()==2
end
-- 装备限制的值函数：仅当尝试装备的目标 c 等于该效果记录的对象怪兽时返回 true，即这些装备卡只能装备给作为对象的怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
