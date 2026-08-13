--WW－クリスタル・ベル
-- 效果：
-- 「风魔女-冬铃」＋「风魔女」怪兽
-- 「风魔女-水晶钟」的①②的效果1回合各能使用1次。
-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
-- ②：这张卡被对方破坏送去墓地的场合，以自己墓地1只「风魔女-冬铃」和1只4星以下的「风魔女」怪兽为对象才能发动。那些怪兽特殊召唤。
function c25793414.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「风魔女-水晶钟」注册融合召唤手续：素材为1只「风魔女-冬铃」（卡号14577226）和1只「风魔女」字段怪兽，sub与insf参数均设为true。
	aux.AddFusionProcCodeFun(c,14577226,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf0),1,true,true)
	-- 「风魔女-水晶钟」的①②的效果1回合各能使用1次。①：以自己或者对方的墓地1只怪兽为对象才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25793414,0))  --"复制效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,25793414)
	e1:SetTarget(c25793414.cptg)
	e1:SetOperation(c25793414.cpop)
	c:RegisterEffect(e1)
	-- 「风魔女-水晶钟」的①②的效果1回合各能使用1次。②：这张卡被对方破坏送去墓地的场合，以自己墓地1只「风魔女-冬铃」和1只4星以下的「风魔女」怪兽为对象才能发动。那些怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25793414,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,25793415)
	e2:SetCondition(c25793414.spcon)
	e2:SetTarget(c25793414.sptg)
	e2:SetOperation(c25793414.spop)
	c:RegisterEffect(e2)
end
c25793414.material_type=TYPE_SYNCHRO
-- 同调素材检查过滤函数：判断候选素材是否为「风魔女-冬铃」（卡号14577226）或可作为融合素材代用品，并且素材需为同调怪兽类型。
function c25793414.sfcfilter(c,fc)
	return (c:IsFusionCode(14577226) or c:CheckFusionSubstitute(fc)) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 同调融合素材组合检查函数：确认素材组sg中包含满足“冬铃/代替品”（sfcfilter）和满足「风魔女」字段（0xf0）的两只素材，顺序不限。
function c25793414.synchro_fusion_check(tp,sg,fc)
	-- 调用aux.gffcheck检查素材组sg：一只卡满足sfcfilter（冬铃/代替品），另一只卡满足Card.IsFusionSetCard(0xf0)（「风魔女」字段），两种顺序均可。
	return aux.gffcheck(sg,c25793414.sfcfilter,fc,Card.IsFusionSetCard,0xf0)
end
-- 效果①的目标函数：若在连锁选择对象阶段（chkc），校验所选卡在墓地且为怪兽；若在发动前检查（chk==0），确认双方墓地存在至少1只怪兽；发动时提示玩家并从双方墓地选择1只怪兽作为对象。
function c25793414.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsType(TYPE_MONSTER) end
	-- 发动前检查：双方墓地存在至少1只怪兽（可作为①效果对象）时才可发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_MONSTER) end
	-- 弹出“请选择效果的对象”的选择提示，供玩家从墓地选择对象怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从双方墓地选择1只怪兽作为①效果的对象，并登记为连锁对象。
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
end
-- ①效果处理：若本卡仍与效果相关且表侧表示、对象仍与效果相关且不是衍生物，则将本卡卡名改为对象的原本卡名，并在对象不是陷阱怪兽时复制其效果；同时注册一个结束阶段重置复制效果的辅助效果。
function c25793414.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①所选的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 这张卡当作和那只怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		end
		-- 直到结束阶段
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(25793414,2))  --"结束复制效果"
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetLabelObject(e1)
		e2:SetLabel(cid)
		e2:SetOperation(c25793414.rstop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段处理：将复制的效果和变更的卡名重置，使本卡恢复原状；随后显示本卡动画并向对方提示该效果结束。
function c25793414.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 展示本卡的动画，使双方确认复制效果被解除。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家发送“对方选择了：”的提示，并显示本卡描述，告知对方复制效果已结束。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ②效果发动条件：这张卡被对方破坏并送去墓地的场合（破坏由其对方造成，且原先由自己控制）才能发动。
function c25793414.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 特殊召唤对象筛选函数：选择墓地的「风魔女-冬铃」（卡号14577226），并确认其可被特殊召唤。
function c25793414.spfilter1(c,e,tp)
	return c:IsCode(14577226) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤对象筛选函数：选择墓地中「风魔女」字段且等级4以下的怪兽，并确认其可被特殊召唤。
function c25793414.spfilter2(c,e,tp)
	return c:IsSetCard(0xf0) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标函数：需要自己场上有至少2个可用怪兽区域、不受【青眼精灵龙】同时特召限制的影响，并且墓地中有符合条件的冬铃和风魔女怪兽；发动时选择这两只作为对象。
function c25793414.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查墓地中是否存在至少1只符合条件的「风魔女-冬铃」作为特殊召唤对象。
		and Duel.IsExistingTarget(c25793414.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查墓地中是否存在至少1只符合条件的4星以下「风魔女」怪兽作为特殊召唤对象。
		and Duel.IsExistingTarget(c25793414.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出“请选择要特殊召唤的卡”的选择提示（第一次选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只符合条件的「风魔女-冬铃」作为特殊召唤对象，并登记为连锁对象。
	local g1=Duel.SelectTarget(tp,c25793414.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 弹出“请选择要特殊召唤的卡”的选择提示（第二次选择）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只符合条件的4星以下「风魔女」怪兽作为特殊召唤对象，且排除已选的冬铃，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,c25793414.spfilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 将本次效果处理登记为特殊召唤2只怪兽的操作信息，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- ②效果处理：获取连锁对象中仍与效果相关的卡；若自己场上可用区域不足或受【青眼精灵龙】限制不能同时特召2只以上，则效果不处理；否则进行特殊召唤。
function c25793414.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，并过滤出仍然与效果相关的卡片（对象未因离场等原因失效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（不跳过召唤条件/苏生限制的检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
