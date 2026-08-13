--デストーイ・カスタム
-- 效果：
-- ①：以自己墓地1只「锋利小鬼」怪兽或者「毛绒动物」怪兽为对象才能发动。那只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为融合素材的场合，可以当作「魔玩具」怪兽使用。
function c36693940.initial_effect(c)
	-- ①：以自己墓地1只「锋利小鬼」怪兽或者「毛绒动物」怪兽为对象才能发动。那只怪兽特殊召唤。把这个效果特殊召唤的怪兽作为融合素材的场合，可以当作「魔玩具」怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c36693940.target)
	e1:SetOperation(c36693940.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否属于「毛绒动物」或「锋利小鬼」字段，且可以被当前效果特殊召唤。
function c36693940.filter(c,e,tp)
	return c:IsSetCard(0xa9,0xc3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 取对象合法性判定：若是指定对象则为己方墓地且符合过滤条件的怪兽；发动条件检查为场上存在可用怪兽区域且墓地存在符合条件的对象。
function c36693940.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c36693940.filter(chkc,e,tp) end
	-- 发动条件：己方主要怪兽区存在空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：墓地存在至少1只符合过滤条件且能成为效果对象的怪兽。
		and Duel.IsExistingTarget(c36693940.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从自己墓地选择1只符合条件的怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c36693940.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：将进行1只怪兽的特殊召唤，供其他卡的效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象卡仍与效果关联则将其表侧表示特殊召唤；若特殊召唤成功，给那只怪兽附加可当作「魔玩具」使用的效果。
function c36693940.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果关联且特殊召唤成功，才执行后续赋予字段效果的处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 把这个效果特殊召唤的怪兽作为融合素材的场合，可以当作「魔玩具」怪兽使用。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(36693940,0))  --"「魔玩具改造」效果适用中"
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_FUSION_SETCODE)
		e1:SetValue(0xad)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
