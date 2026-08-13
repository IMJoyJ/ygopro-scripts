--RUM－アストラル・フォース
-- 效果：
-- ①：以自己场上1只阶级最高的超量怪兽为对象才能发动。和那只自己怪兽相同种族·属性而阶级高2阶的1只怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：这张卡在墓地存在的场合，自己抽卡阶段的抽卡前才能发动。这张卡加入手卡。这个效果发动的回合，自己不能进行通常抽卡，不能用「升阶魔法-星光之力」的效果以外把怪兽特殊召唤。
function c45950291.initial_effect(c)
	-- ①：以自己场上1只阶级最高的超量怪兽为对象才能发动。和那只自己怪兽相同种族·属性而阶级高2阶的1只怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c45950291.target)
	e1:SetOperation(c45950291.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，自己抽卡阶段的抽卡前才能发动。这张卡加入手卡。这个效果发动的回合，自己不能进行通常抽卡，不能用「升阶魔法-星光之力」的效果以外把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45950291,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c45950291.thcon)
	e2:SetCost(c45950291.thcost)
	e2:SetTarget(c45950291.thtg)
	e2:SetOperation(c45950291.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示且阶级大于参数 rk，用于检查场上是否存在阶级更高的超量怪兽。
function c45950291.cfilter(c,rk)
	return c:IsFaceup() and c:GetRank()>rk
end
-- 对象选择过滤：c 必须是表侧表示的超量怪兽，且自己场上不存在阶级高于 c 的超量怪兽；额外卡组中存在与 c 相同种族·属性、阶级高 2 阶且可作为超量素材特殊召唤的怪兽；同时 c 满足超量素材的使用限制。
function c45950291.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查自己场上不存在阶级高于该超量怪兽的其他怪兽，以保证其是阶级最高的超量怪兽。
		and not Duel.IsExistingMatchingCard(c45950291.cfilter,tp,LOCATION_MZONE,0,1,nil,rk)
		-- 检查额外卡组是否存在符合条件的怪兽（与对象怪兽相同种族·属性、阶级高 2 阶、可作为超量素材且能特殊召唤）。
		and Duel.IsExistingMatchingCard(c45950291.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+2,c:GetRace(),c:GetAttribute(),c:GetCode())
		-- 检查 c 是否满足超量素材的相关限制（未受必须作为超量素材的效果束缚才能作为对象）。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组选怪过滤：候选怪兽必须阶级为 rk、与对象怪兽种族·属性相同，可作为其超量素材，并能以超量召唤方式特殊召唤；若候选怪兽是 6165656 号（CNo.101）则要求对象怪兽必须是 48995978 号（No.101）；同时需要额外怪兽区有可用空格。
function c45950291.filter2(c,e,tp,mc,rk,rc,att,code)
	if c:GetOriginalCode()==6165656 and code~=48995978 then return false end
	return c:IsRank(rk) and c:IsRace(rc) and c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 检查将对象怪兽作为素材叠放后，额外卡组怪兽 c 是否有可用的特殊召唤区域（额外怪兽区空格）。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动的目标处理：确认场上存在可选对象后，选择自己场上 1 只阶级最高的超量怪兽作为对象，并设置特殊召唤的操作信息。
function c45950291.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c45950291.filter1(chkc,e,tp) end
	-- 合法性检查：自己场上是否存在满足 filter1 的可用对象（阶级最高的超量怪兽且能进行升阶召唤）。
	if chk==0 then return Duel.IsExistingTarget(c45950291.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择对象的提示（请选择效果的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择 1 只符合条件的超量怪兽作为效果对象，并建立与该连锁的关联。
	Duel.SelectTarget(tp,c45950291.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本次效果将把额外卡组的 1 只怪兽特殊召唤，用于连锁检测和效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：确认对象合法后，从额外卡组选择符合条件的怪兽，将对象及其原有超量素材叠放在新怪兽下方，以超量召唤方式特殊召唤，并完成超量召唤手续。
function c45950291.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时该连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次确认对象怪兽仍满足超量素材相关限制，否则效果不适用。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择要特殊召唤的怪兽的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择 1 只符合条件的怪兽（与对象怪兽相同种族·属性、阶级高 2 阶、可作为素材并特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c45950291.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+2,tc:GetRace(),tc:GetAttribute(),tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原有的超量素材全部叠放到新怪兽下方作为其超量素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽自身叠放到新怪兽下方，作为其超量素材（升阶召唤的素材）。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新怪兽以超量召唤的方式表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 墓地效果的发动条件：仅在自己的回合（抽卡阶段抽卡前）可以发动。
function c45950291.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否为回合玩家，即只允许在自己回合发动。
	return tp==Duel.GetTurnPlayer()
end
-- 发动代价：需要本回合尚未进行过特殊召唤且能进行通常抽卡；发动后放弃本回合通常抽卡，并给自己附加只能用本卡效果特殊召唤的自肃，以及对应的誓约限制。
function c45950291.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：玩家本回合尚未进行过特殊召唤，且可以进行通常抽卡。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	local c=e:GetHandler()
	-- 这个效果发动的回合，自己不能用「升阶魔法-星光之力」的效果以外把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45950291.splimit)
	-- 将‘不能用「升阶魔法-星光之力」的效果以外把怪兽特殊召唤’的自肃效果注册到当前玩家。
	Duel.RegisterEffect(e1,tp)
	-- 这个效果发动的回合，自己不能进行通常抽卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(63060238)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘自己不能进行通常抽卡’的限制效果注册到当前玩家。
	Duel.RegisterEffect(e2,tp)
	-- 放弃本回合的通常抽卡（代替抽卡，把本卡加入手牌），并标记为誓约限制。
	aux.GiveUpNormalDraw(e,tp,EFFECT_FLAG_OATH)
end
-- 自肃判定函数：仅允许「升阶魔法-星光之力」（45950291）的效果进行的特殊召唤，其他特殊召唤均被禁止。
function c45950291.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not se:GetHandler():IsCode(45950291)
end
-- 墓地效果的发动目标：确认此卡能加入手卡，并设置回手牌的操作信息。
function c45950291.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：声明要将此卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡从墓地加入手卡，并向对方玩家展示确认。
function c45950291.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以效果原因送去（加入）持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示这张卡，以确认其已加入手卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
