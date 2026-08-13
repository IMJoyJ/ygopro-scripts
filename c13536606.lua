--V－LAN ヒドラ
-- 效果：
-- 衍生物以外的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力上升和这张卡互相连接的怪兽数量×300。
-- ②：以这张卡所互相连接区1只连接3以下的怪兽为对象才能发动。那只怪兽解放，那个连接标记数量的「V-LAN衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个回合自己不能把连接标记数量和作为对象的怪兽相同的怪兽特殊召唤。
function c13536606.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设置连接召唤手续：用2只以上满足matfilter过滤的怪兽（衍生物以外的怪兽）作为连接素材。
	aux.AddLinkProcedure(c,c13536606.matfilter,2)
	-- ①：这张卡的攻击力上升和这张卡互相连接的怪兽数量×300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c13536606.atkval)
	c:RegisterEffect(e1)
	-- ②：以这张卡所互相连接区1只连接3以下的怪兽为对象才能发动。那只怪兽解放，那个连接标记数量的「V-LAN衍生物」（电子界族·光·1星·攻/守0）在自己场上特殊召唤。这个回合自己不能把连接标记数量和作为对象的怪兽相同的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13536606,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,13536606)
	e2:SetTarget(c13536606.tktg)
	e2:SetOperation(c13536606.tkop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤函数：连接召唤的素材必须是衍生物以外的怪兽（用IsLinkType判定其作为连接素材时的种类不是衍生物）。
function c13536606.matfilter(c)
	return not c:IsLinkType(TYPE_TOKEN)
end
-- 攻击力上升值的计算：返回这张卡当前互相连接的怪兽数量×300。
function c13536606.atkval(e,c)
	return c:GetMutualLinkedGroupCount()*300
end
-- 选择对象的过滤条件：对象必须为表侧表示、连接怪兽、连接标记数不超过可特召空格数（且不超过3）、可被效果解放、处于这张卡的互相连接区域；若解放对象后空格数大于1且青眼精灵龙的限制效果适用中，则不能选择（避免同时特殊召唤2只以上怪兽）。
function c13536606.rfilter(c,tp,g)
	-- 计算解放对象c后，tp玩家场上可用的怪兽区数量，用于判断能否特召足够数量的衍生物。
	local ft=Duel.GetMZoneCount(tp,c)
	local lk=math.min(3,ft)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsLinkBelow(lk) and c:IsReleasableByEffect() and g:IsContains(c)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and (ft==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
end
-- ②效果的发动时处理：获取这张卡的互相连接组；若指定对象则检查其是否在怪兽区且满足rfilter；若为发动合法性检查，则确认存在满足条件的对象，且玩家当前能特殊召唤「V-LAN衍生物」。
function c13536606.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetMutualLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c13536606.rfilter(chkc,tp,lg) end
	-- 发动合法性检查：确认场上存在至少1只满足rfilter条件的对象（即互相连接区里可解放的连接3以下怪兽），作为效果发动的必要目标。
	if chk==0 then return Duel.IsExistingTarget(c13536606.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,lg)
		-- 同时确认tp玩家当前可以特殊召唤「V-LAN衍生物」（电子界族·光·1星·攻/守0），否则效果不能发动。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,13536607,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 给玩家显示“请选择要解放的卡”的选择提示，用于后续选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让tp玩家从双方怪兽区选择1只满足rfilter条件的怪兽作为效果对象，并自动登记为当前连锁的对象。
	local rg=Duel.SelectTarget(tp,c13536606.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,lg)
	local ct=rg:GetFirst():GetLink()
	-- 设置操作信息：本效果将生成ct（对象连接标记数量）只衍生物，分类为CATEGORY_TOKEN。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设置操作信息：本效果将特殊召唤ct只怪兽，分类为CATEGORY_SPECIAL_SUMMON。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- ②效果处理：取对象，确认对象仍与效果相关且不免疫后解放之；解放成功则根据可用怪兽区空格数和青眼精灵龙限制判断能否特召，若可以则依次创建并特殊召唤ct只「V-LAN衍生物」；最后给本方玩家附加直到结束阶段的自肃效果：不能特殊召唤与对象连接标记数量相同的怪兽。
function c13536606.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetLink()
	-- 检查对象仍与效果e有关联（未因离场等原因解除联系）、且不受此效果影响，若满足则将其解放；解放成功（返回解放数>0）才继续处理。
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and Duel.Release(tc,REASON_EFFECT)>0 then
		-- 获取tp玩家主要怪兽区当前的可用空格数，用于判断能否特殊召唤ct只衍生物。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft<ct or (ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
		-- 再次确认tp玩家可以特殊召唤「V-LAN衍生物」，若不能则直接结束效果处理，不进行特殊召唤。
		if not Duel.IsPlayerCanSpecialSummonMonster(tp,13536607,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then return end
		for i=1,ct do
			-- 创建1只「V-LAN衍生物」（卡号13536607）于tp方场上。
			local token=Duel.CreateToken(tp,13536607)
			-- 将衍生物以表侧攻击表示特殊召唤到tp场上，作为连续特殊召唤的一步。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		end
		-- 完成连续特殊召唤流程，统一处理本次特殊召唤的衍生物。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合自己不能把连接标记数量和作为对象的怪兽相同的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabel(ct)
	e1:SetTarget(c13536606.splimit)
	-- 将自肃效果e1注册给tp玩家，以玩家为对象施加“不能特殊召唤”的限制，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：若怪兽的连接标记数量等于效果保存的Label值（即被解放对象的连接标记数），则该怪兽不能特殊召唤。
function c13536606.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLink(e:GetLabel())
end
