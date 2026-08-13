--凍てし心が映す神影
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是「影依」怪兽不能从额外卡组特殊召唤。
-- ①：作为这张卡的发动时的效果处理，从额外卡组把1只融合怪兽送去墓地。
-- ②：把自己场上1只融合怪兽解放才能发动。和那只怪兽属性不同的1只「影依」融合怪兽从额外卡组当作融合召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0。
local s,id,o=GetID()
-- 初始化函数：为该卡创建并注册两个效果：①作为魔法卡发动时，从额外卡组将1只融合怪兽送去墓地；②起动效果，解放自己场上1只融合怪兽，从额外卡组特殊召唤1只属性不同的「影依」融合怪兽；同时注册特殊召唤活动计数器用于回合内自肃。
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从额外卡组把1只融合怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把自己场上1只融合怪兽解放才能发动。和那只怪兽属性不同的1只「影依」融合怪兽从额外卡组当作融合召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(0)
	e2:SetCost(s.cost)
	e2:SetTarget(s.fustg)
	e2:SetOperation(s.fusop)
	e2:SetCountLimit(1,id+o)
	c:RegisterEffect(e2)
	-- 注册代号为该卡id的特殊召唤活动计数器，若特殊召唤操作触发counterfilter返回false则计数，用于在①/②发动时检测本回合是否已进行过自肃禁止的特殊召唤。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：对本次特殊召唤进行判断，若不是从额外卡组特殊召唤，或是表侧表示的「影依」怪兽，则不计数；否则（从额外卡组特殊召唤非「影依」或里侧「影依」）会计入自肃计数。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x9d) and c:IsFaceup()
end
-- ①/②共用的发动费用：检查本回合尚未触发自肃（计数为0）；通过后为当前玩家注册一个誓约效果，使其本回合不能从额外卡组特殊召唤非「影依」怪兽（回合结束重置）。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检查：确认该玩家本回合的特殊召唤自肃计数为0，即尚未从额外卡组特殊召唤过非「影依」怪兽，允许发动。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是「影依」怪兽不能从额外卡组特殊召唤。①：作为这张卡的发动时的效果处理，从额外卡组把1只融合怪兽送去墓地。②：把自己场上1只融合怪兽解放才能发动。和那只怪兽属性不同的1只「影依」融合怪兽从额外卡组当作融合召唤作特殊召唤。这个效果特殊召唤的怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	-- 将自肃效果e1注册到当前玩家tp，生效期间限制其不能从额外卡组特殊召唤非「影依」怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制判定：若尝试特殊召唤的怪兽不是「影依」且从额外卡组而来，则禁止该特殊召唤。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x9d) and c:IsLocation(LOCATION_EXTRA)
end
-- ①效果的送墓对象筛选：必须是融合怪兽且能够被效果送去墓地。
function s.tgfilter(c)
	return c:IsAbleToGrave() and c:IsType(TYPE_FUSION)
end
-- ①效果发动目标：检查额外卡组是否有满足tgfilter的融合怪兽；若有，则设置本次操作会将1张额外卡组的卡送去墓地。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①效果发动合法性检查：额外卡组中存在至少1只可送去墓地的融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 预设置①效果的操作信息：将1张额外卡组卡牌送去墓地（用于连锁检测和时点判断）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：从额外卡组选择1只融合怪兽送去墓地，作为这张卡发动时的效果处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从自己额外卡组选择1只满足tgfilter的融合怪兽（作为送墓对象）。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的融合怪兽以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的解放对象筛选：c必须是融合怪兽，且额外卡组中存在与c属性不同的「影依」融合怪兽，并且能通过后续条件特殊召唤。
function s.fusfilter1(c,e,tp)
	-- 具体判定：c是融合怪兽，且以c的属性为排除条件，额外卡组中存在至少1只满足fusfilter2（属性不同且可融合召唤）的「影依」融合怪兽。
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.fusfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute(),c)
end
-- ②效果的特殊召唤对象筛选：该额外卡组怪兽必须是「影依」融合怪兽，属性与解放怪兽不同，能够以融合召唤方式特殊召唤，满足融合素材条件，并且有可用的特殊召唤区域。
function s.fusfilter2(c,e,tp,att,mc)
	return c:IsSetCard(0x9d) and not c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
		and c:CheckFusionMaterial()
		-- 确认解放该怪兽后，自己的额外卡组怪兽仍有可用的特殊召唤区域（考虑额外怪兽区及主怪兽区空格）。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果发动目标处理：检查自肃、解放对象和特殊召唤可行性均满足后，选择1只融合怪兽解放，记录其属性，并预宣布进行特殊召唤。
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if not e:IsCostChecked() then return false end
		-- 目标合法性检查：场上存在至少1只可作为解放对象的融合怪兽（且不存在必须作为融合素材的卡组限制），满足发动条件。
		return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) and Duel.CheckReleaseGroup(tp,s.fusfilter1,1,nil,e,tp)
			and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
	end
	e:SetLabel(0)
	-- 从自己场上选择1只符合fusfilter1的融合怪兽作为解放代价。
	local rg=Duel.SelectReleaseGroup(tp,s.fusfilter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetAttribute())
	-- 将选中的融合怪兽解放，作为②效果的发动费用。
	Duel.Release(rg,REASON_COST)
	-- 预设置②效果的操作信息：将从额外卡组特殊召唤1只怪兽（具体对象不取对象，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：再次确认素材限制后，从额外卡组选择1只符合条件的「影依」融合怪兽，以融合召唤方式特殊召唤，并让它攻击力变成0。
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时若存在必须作为融合素材的限制效果导致无法融合召唤，则效果不处理。
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	local att=e:GetLabel()
	-- 显示选择提示，引导玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足fusfilter2的「影依」融合怪兽作为特殊召唤对象（属性与解放怪兽不同且可融合召唤）。
	local g=Duel.SelectMatchingCard(tp,s.fusfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,att,nil)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 以融合召唤方式将选中的怪兽特殊召唤（分步特殊召唤；若成功则继续施加攻击力变化效果）。
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的攻击力变成0。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成本次分步特殊召唤的结算，正式宣告所选的融合怪兽特殊召唤成功。
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
end
