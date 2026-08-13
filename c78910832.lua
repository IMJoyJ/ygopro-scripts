--ビック・バイパー Type－L
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己战斗阶段开始时，可以从以下效果选择1个发动。
-- ●从手卡把1只机械族怪兽特殊召唤。
-- ●从卡组把1只4星以下的机械族·光属性怪兽送去墓地。
-- ②：这张卡被破坏的场合，以自己墓地1只机械族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
local s,id,o=GetID()
-- 初始化并注册「V形蛇 L型」的两个效果：e1为在自己战斗阶段开始时发动、从特殊召唤和送去墓地两个选项中选一个处理的诱发选发效果（1回合1次）；e2为这张卡被破坏时以自己墓地1只机械族·光属性怪兽为对象将其特殊召唤的诱发选发效果（1回合1次）。
function s.initial_effect(c)
	-- ①：自己战斗阶段开始时，可以从以下效果选择1个发动。●从手卡把1只机械族怪兽特殊召唤。●从卡组把1只4星以下的机械族·光属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合，以自己墓地1只机械族·光属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：只有自己的回合才能发动（战斗阶段开始时的时点限定在自己的回合）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己，是自己的回合才满足发动条件。
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤对象的过滤函数：手卡中可以被特殊召唤的机械族怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 送去墓地对象的过滤函数：4星以下的机械族·光属性且可以送去墓地的怪兽。
function s.tgfilter(c)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsAbleToGrave()
end
-- ①效果的目标选择处理：分别判断「从手卡特殊召唤」和「从卡组送去墓地」两个选项是否可用，发动条件为至少一个可用；发动时让玩家从可用选项中选择1个，记录所选选项并据此设置对应的操作信息（特殊召唤或送去墓地）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己主要怪兽区是否有可用空格（选项一的前提之一）。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己手卡是否存在可以特殊召唤的机械族怪兽（选项一可用的另一前提）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	-- 判断自己卡组是否存在4星以下的机械族·光属性且可以送去墓地的怪兽（选项二是否可用）。
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从「特殊召唤」「送去墓地」两个可用选项中选择1个发动。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"送去墓地"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 选择特殊召唤时，设置操作信息：将从手卡把1只怪兽特殊召唤（对象处理时不确定，故targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
		end
		-- 选择送去墓地时，设置操作信息：将从卡组把1只怪兽送去墓地（对象处理时不确定，故targets为nil）。
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- ①效果的处理：若选择的是特殊召唤，则在主要怪兽区有空格时从手卡选1只机械族怪兽特殊召唤；若选择的是送去墓地，则从卡组选1只4星以下的机械族·光属性怪兽送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 再次确认自己主要怪兽区还有可用空格，没有则不能进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡选择1只可以特殊召唤的机械族怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 把选择的怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组选择1只4星以下的机械族·光属性且可以送去墓地的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 把选择的怪兽以效果原因送去墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- ②效果对象卡的过滤函数：自己墓地中可以被特殊召唤的机械族·光属性怪兽。
function s.spfilter2(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标选择处理：先校验连锁中选择的对象是否是自己墓地的机械族·光属性怪兽；发动条件为自己主要怪兽区有空格且自己墓地存在可以成为对象的机械族·光属性怪兽。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter2(chkc,e,tp) end
	-- 发动条件检查：自己主要怪兽区必须有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在可以成为效果对象的、可以特殊召唤的机械族·光属性怪兽。
		and Duel.IsExistingTarget(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家以自己墓地1只机械族·光属性怪兽为对象，并将其设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：将把作为对象的1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的处理：取得对象卡，若对象仍与连锁相关且不受王家长眠之谷影响，则将其特殊召唤；若该怪兽原本攻击力在1200以下，则特殊召唤成功后赋予其攻击力上升1200的永续效果。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与这条连锁相关，且不受王家长眠之谷的影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 分步把对象怪兽以表侧表示特殊召唤到自己场上，并确认特殊召唤成功。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		and tc:GetBaseAttack()<=1200 then
		-- 这个效果把原本攻击力是1200以下的怪兽特殊召唤的场合，那个攻击力上升1200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 完成分步特殊召唤的收尾处理（与Duel.SpecialSummonStep配套调用）。
	Duel.SpecialSummonComplete()
end
