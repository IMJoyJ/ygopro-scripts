--WW－クリスタル・ベル
-- 效果：
-- 「风魔女-冬铃」＋「风魔女」怪兽
-- 「风魔女-水晶钟」的①②的效果1回合各能使用1次。
-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
-- ②：这张卡被对方破坏送去墓地的场合，以自己墓地1只「风魔女-冬铃」和1只4星以下的「风魔女」怪兽为对象才能发动。那些怪兽特殊召唤。
function c25793414.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为14577226的怪兽和1个满足条件的「风魔女」怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,14577226,aux.FilterBoolFunction(Card.IsFusionSetCard,0xf0),1,true,true)
	-- ①：以自己或者对方的墓地1只怪兽为对象才能发动。直到结束阶段，这张卡当作和那只怪兽同名卡使用，得到相同效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25793414,0))  --"复制效果"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,25793414)
	e1:SetTarget(c25793414.cptg)
	e1:SetOperation(c25793414.cpop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合，以自己墓地1只「风魔女-冬铃」和1只4星以下的「风魔女」怪兽为对象才能发动。那些怪兽特殊召唤。
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
-- 用于判断融合素材是否满足条件的过滤函数，判断是否为「风魔女-冬铃」或可替代的融合怪兽且为同调怪兽
function c25793414.sfcfilter(c,fc)
	return (c:IsFusionCode(14577226) or c:CheckFusionSubstitute(fc)) and c:IsFusionType(TYPE_SYNCHRO)
end
-- 用于验证融合素材是否满足条件的函数，使用gffcheck函数检查是否恰好包含一张满足sfcfilter条件和一张满足Card.IsFusionSetCard(0xf0)条件的卡
function c25793414.synchro_fusion_check(tp,sg,fc)
	-- 检查融合素材是否恰好包含一张满足sfcfilter条件和一张满足Card.IsFusionSetCard(0xf0)条件的卡
	return aux.gffcheck(sg,c25793414.sfcfilter,fc,Card.IsFusionSetCard,0xf0)
end
-- 设置效果目标为墓地中的任意一只怪兽
function c25793414.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsType(TYPE_MONSTER) end
	-- 检查是否满足发动条件，即墓地存在至少一只怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,TYPE_MONSTER) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地中的任意一只怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
end
-- 执行复制效果，将目标怪兽的卡号复制到自身，并复制其效果
function c25793414.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		local cid=0
		-- 将自身卡号更改为目标怪兽的卡号
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
		-- 设置一个持续到结束阶段的效果，用于在结束阶段清除复制效果
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
-- 结束阶段时清除复制效果的处理函数
function c25793414.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家“对方选择了：结束复制效果”
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 判断该卡是否因对方破坏而送去墓地，且为己方控制者
function c25793414.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 判断墓地中的怪兽是否为「风魔女-冬铃」且可特殊召唤
function c25793414.spfilter1(c,e,tp)
	return c:IsCode(14577226) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断墓地中的怪兽是否为「风魔女」且等级为4以下且可特殊召唤
function c25793414.spfilter2(c,e,tp)
	return c:IsSetCard(0xf0) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标，检查是否满足特殊召唤条件
function c25793414.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查是否满足特殊召唤条件，即墓地存在至少一只「风魔女-冬铃」
		and Duel.IsExistingTarget(c25793414.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查是否满足特殊召唤条件，即墓地存在至少一只4星以下的「风魔女」怪兽
		and Duel.IsExistingTarget(c25793414.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的「风魔女-冬铃」作为特殊召唤目标
	local g1=Duel.SelectTarget(tp,c25793414.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的4星以下的「风魔女」怪兽作为特殊召唤目标
	local g2=Duel.SelectTarget(tp,c25793414.spfilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp)
	g1:Merge(g2)
	-- 设置操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 执行特殊召唤操作，将选择的怪兽特殊召唤到场上
function c25793414.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的特殊召唤目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>0 then
		-- 将目标卡组特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
