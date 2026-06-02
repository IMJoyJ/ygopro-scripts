--超越召喚獣アイオーン
-- 效果：
-- 属性不同的融合怪兽×2只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡融合召唤的场合才能发动。把最多有那些作为融合素材的怪兽数量的自己·对方的场上·墓地的卡除外。3只以上为素材的场合，可以再把对方的额外卡组确认并从那之中让最多3张除外。
-- ②：自己·对方回合，宣言1个属性才能发动。这张卡以外的场上的全部怪兽直到回合结束时变成宣言的属性。
local s,id,o=GetID()
-- 注册卡片效果：注册融合素材要求，以及①效果（融合召唤成功时除外卡片）和②效果（宣言属性改变场上怪兽属性）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 属性不同的融合怪兽×2只以上
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_FUSION_MATERIAL)
	e0:SetCondition(s.FSCondition)
	e0:SetOperation(s.FSOperation)
	c:RegisterEffect(e0)
	-- ①：这张卡融合召唤的场合才能发动。把最多有那些作为融合素材的怪兽数量的自己·对方的场上·墓地的卡除外。3只以上为素材的场合，可以再把对方的额外卡组确认并从那之中让最多3张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外效果"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，宣言1个属性才能发动。这张卡以外的场上的全部怪兽直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"改变属性"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
end
-- 过滤条件：必须是融合怪兽且能作为融合素材。
function s.FSFilter(c,fc)
	return c:IsType(TYPE_FUSION) and c:IsCanBeFusionMaterial(fc)
end
-- 素材组检查：检查所选素材组合是否满足调弦之魔术师、必须作为素材等限制以及额外卡组怪兽出场的区域空格数检测。
function s.FSFilter1(g,fc,gc,tp,chkf)
	if gc and not g:IsContains(gc) then return false end
	-- 检查素材组中是否包含有调弦之魔术师的特殊融合素材限制。
	if g:IsExists(aux.TuneMagicianCheckX,1,nil,g,EFFECT_TUNE_MAGICIAN_F) then return false end
	-- 检查素材组中是否存在受到必须作为融合素材效果限制的卡片。
	if not aux.MustMaterialCheck(g,tp,EFFECT_MUST_BE_FMATERIAL) then return false end
	-- 如果存在额外的融合素材过滤规则，则调用进行验证。
	if aux.FCheckAdditional and not aux.FCheckAdditional(tp,g,fc)
		-- 如果存在额外的融合终结条件过滤规则，则调用进行验证。
		or aux.FGoalCheckAdditional and not aux.FGoalCheckAdditional(tp,g,fc) then return false end
	-- 检查在额外卡组怪兽出场时是否有可用的怪兽空格数。
	return chkf==PLAYER_NONE or Duel.GetLocationCountFromEx(tp,tp,g,fc)>0
end
-- 融合素材的选择条件判定：设置各素材属性互不相同的额外过滤条件，并进行子组检查。
function s.FSCondition(e,g,gc,chkf)
	-- 如果在没有给定卡片组时调用，检查是否受必须成为融合素材效果的影响。
	if g==nil then return aux.MustMaterialCheck(nil,e:GetHandlerPlayer(),EFFECT_MUST_BE_FMATERIAL) end
	local c=e:GetHandler()
	local mg=g:Filter(s.FSFilter,nil,c)
	local tp=e:GetHandlerPlayer()
	local res=false
	-- 设置融合素材选择的追加过滤函数：选取的素材卡片属性必须互不相同。
	aux.GCheckAdditional=aux.dabcheck
	if gc then
		if not mg:IsContains(gc) then
			-- 清除设置的融合素材属性各不相同的追加过滤规则。
			aux.GCheckAdditional=nil
			return false
		end
		res=mg:CheckSubGroup(s.FSFilter1,2,99,c,gc,tp,chkf)
	else
		res=mg:CheckSubGroup(s.FSFilter1,2,99,c,nil,tp,chkf)
	end
	-- 清除设置的融合素材属性各不相同的追加过滤规则。
	aux.GCheckAdditional=nil
	return res
end
-- 融合召唤的素材选取操作：在选取的素材属性互不相同的条件下，让玩家选择融合素材并注册为融合素材。
function s.FSOperation(e,tp,eg,ep,ev,re,r,rp,gc,chkf)
	local c=e:GetHandler()
	local mg=eg:Filter(s.FSFilter,nil,c)
	-- 设置素材选择时的追加过滤函数：选取的素材卡属性必须互不相同。
	aux.GCheckAdditional=aux.dabcheck
	local g=nil
	while not g do
		if gc then
			-- 提示玩家选择要作为融合素材的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
			g=mg:SelectSubGroup(tp,s.FSFilter1,true,2,99,c,gc,tp,chkf)
		else
			-- 提示玩家选择要作为融合素材的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)  --"请选择要作为融合素材的卡"
			g=mg:SelectSubGroup(tp,s.FSFilter1,true,2,99,c,nil,tp,chkf)
		end
	end
	-- 清除设置的融合素材属性各不相同的追加过滤规则。
	aux.GCheckAdditional=nil
	-- 将选定的卡片组登记为本次融合召唤使用的融合素材。
	Duel.SetFusionMaterial(g)
end
-- 检查①效果的发动条件：此卡融合召唤成功。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的发动目标：计算融合素材数量，检查场上或墓地是否存在可除外的卡，设置除外操作信息，并用Label记录素材数量和追加效果触发标记。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetMaterialCount()
	-- 在发动检测时，确认作为融合素材的怪兽数量大于0，且双方场上或墓地有可除外的卡片。
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	-- 获取己方与对方场上、墓地中所有可除外的卡片。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	if ct>2 then
		e:SetLabel(ct,1)
	else
		e:SetLabel(ct,2)
	end
	-- 设置操作信息：效果处理时会将场上或墓地的卡片除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果处理：根据融合素材数量，将自己·对方的场上·墓地的卡除外；若是3只以上为素材融召，可再把对方额外卡组确认并除外最多3张。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct,res=e:GetLabel()
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家在场上·墓地选择最多相当于素材数量的卡片（受王家长眠之谷效果过滤影响）。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToRemove),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,ct,nil)
	if #sg>0 then
		-- 为选择的被除外卡片显示选中状态的动画。
		Duel.HintSelection(sg)
		-- 将选中的卡片以正面表示除外。
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0
			-- 判断是否成功除外卡片，且素材数在3只以上，且对方额外卡组存在可除外的卡。
			and res==1 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil)
			-- 询问玩家是否发动追加效果：确认对方额外卡组并除外最多3张卡片。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否除外额外？"
			-- 中断效果处理，使得之后对方额外卡组的除外不与先前的除外视为同时处理。
			Duel.BreakEffect()
			-- 获取对方额外卡组中的全部卡片。
			local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
			-- 向己方玩家展示对方额外卡组的所有卡片。
			Duel.ConfirmCards(tp,g,true)
			-- 提示玩家选择要除外的对方额外卡组卡片。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local rg=g:FilterSelect(tp,Card.IsAbleToRemove,1,3,nil)
			-- 将选出的对方额外卡组的卡片除外。
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			-- 将对方的额外卡组洗牌。
			Duel.ShuffleExtra(1-tp)
		end
	end
end
-- ②效果的发动目标：检查是否存在除此卡外的表侧表示怪兽，让玩家宣言一个属性并用Label记录。
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查场上是否存在此卡以外的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除了这张卡以外的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	local att=0
	-- 遍历符合条件的怪兽，以计算可供宣言的属性。
	for tc in aux.Next(g) do
		att=bit.bor(att,(0x7f-tc:GetAttribute()))
	end
	-- 提示玩家宣言一个属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个可宣言的属性。
	local ratt=Duel.AnnounceAttribute(tp,1,att)
	e:SetLabel(ratt)
end
-- ②效果的处理：将除这张卡以外的场上全部怪兽的属性直到回合结束时变成宣言的属性。
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除了这张卡（且与此效果有关联的卡）以外的所有表侧表示怪兽。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 遍历场上除此卡外的所有表侧表示怪兽。
	for tc in aux.Next(g) do
		-- 直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
