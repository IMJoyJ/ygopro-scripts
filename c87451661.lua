--スカーレッド・デーモン
-- 效果：
-- 调整＋调整以外的暗属性怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「红莲魔龙」使用。
-- ②：这张卡从怪兽区域送去墓地的场合才能发动。从额外卡组把1只「红莲魔龙」当作同调召唤作特殊召唤。这张卡作为龙族·暗属性同调怪兽的同调素材送去墓地的场合，可以再把对方场上的攻击表示怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、苏生限制、卡名变更效果、送墓特召及素材检测效果。
function s.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的暗属性怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- 设置这张卡在场上·墓地存在时卡名当作「红莲魔龙」使用的效果。
	aux.EnableChangeCode(c,70902743,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡从怪兽区域送去墓地的场合才能发动。从额外卡组把1只「红莲魔龙」当作同调召唤作特殊召唤。这张卡作为龙族·暗属性同调怪兽的同调素材送去墓地的场合，可以再把对方场上的攻击表示怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡作为龙族·暗属性同调怪兽的同调素材送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetOperation(s.matcheck)
	c:RegisterEffect(e2)
end
-- 检查发动条件：这张卡是否从怪兽区域送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤额外卡组中可以当作同调召唤特殊召唤的「红莲魔龙」。
function s.spfilter(c,e,tp)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤所需的可用怪兽区域数量是否大于0。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动的目标检查与处理，确认是否存在可特殊召唤的「红莲魔龙」并进行素材限制检测。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查玩家是否受到必须作为同调素材等规则限制效果的影响。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「红莲魔龙」。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	e:SetLabel(e:GetHandler():GetFlagEffect(id))
end
-- 效果处理函数：从额外卡组特殊召唤「红莲魔龙」，若满足素材条件则可选择破坏对方场上所有攻击表示怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时再次检查是否满足必须作为同调素材的规则限制，不满足则不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「红莲魔龙」。
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选择的怪兽以同调召唤的形式表侧表示特殊召唤，若特殊召唤成功则进行后续处理。
		if Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			tc:CompleteProcedure()
			-- 获取对方场上所有处于攻击表示的怪兽。
			local dg=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
			if dg:GetCount()>0 and e:GetLabel()>0
				-- 询问玩家是否发动追加效果，将对方场上的攻击表示怪兽全部破坏。
				and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把对方场上的攻击表示怪兽全部破坏？"
				-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行。
				Duel.BreakEffect()
				-- 因效果将获取到的对方场上的攻击表示怪兽全部破坏。
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end
-- 素材检测函数：若作为龙族·暗属性同调怪兽的同调素材送去墓地，则为自身注册一个标记，用于后续追加破坏效果的判定。
function s.matcheck(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if r==REASON_SYNCHRO and rc:IsRace(RACE_DRAGON) and rc:IsAttribute(ATTRIBUTE_DARK) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
	end
end
