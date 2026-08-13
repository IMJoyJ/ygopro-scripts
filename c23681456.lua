--マドルチェ・ハッピーフェスタ
-- 效果：
-- 从手卡把名字带有「魔偶甜点」的怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。
function c23681456.initial_effect(c)
	-- 从手卡把名字带有「魔偶甜点」的怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23681456.target)
	e1:SetOperation(c23681456.operation)
	c:RegisterEffect(e1)
end
-- 筛选手卡中持有「魔偶甜点」字段且能够被本次效果特殊召唤的怪兽。
function c23681456.filter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点的目标处理函数：确认自己场上存在可用的怪兽区域且手卡中有符合条件的「魔偶甜点」怪兽，满足则允许发动。
function c23681456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位，作为能否特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡是否存在至少1只可通过效果特殊召唤的「魔偶甜点」怪兽。
		and Duel.IsExistingMatchingCard(c23681456.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，宣告此效果将从手卡进行特殊召唤（预计1张，实际可能更多），供其他卡片的发动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：计算可特殊召唤数量（受可用怪兽区及【青眼精灵龙】限制），从手卡选择任意数量符合条件的「魔偶甜点」怪兽特殊召唤，给这些怪兽记录标识，并注册结束时回卡组的效果。
function c23681456.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己主要怪兽区域的可用空格数，作为本次可特殊召唤怪兽的数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1到可用空格数（ft）张符合条件的「魔偶甜点」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c23681456.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 将选中的怪兽以表侧表示特殊召唤（作为连续特殊召唤的一步，尚未实际完成召唤）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(23681456,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(23681456,0))  --"「魔偶甜点佳节」效果适用中"
			tc=g:GetNext()
		end
		-- 完成所有特殊召唤步骤，正式将选择的多只怪兽特殊召唤到场上。
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c23681456.retcon)
		e1:SetOperation(c23681456.retop)
		-- 将结束阶段时使怪兽回到持有者卡组的效果注册到场上，使其在此后生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定怪兽是否带有本次特殊召唤时记录的唯一标识fid，用于识别“被这个效果特殊召唤的怪兽”。
function c23681456.retfilter(c,fid)
	return c:GetFlagEffectLabel(23681456)==fid
end
-- 回卡组效果的发动条件：若场上仍存在带有本次特召标识的怪兽则执行处理；若不存在，则删除记录并重置该效果。
function c23681456.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c23681456.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段回卡组的处理：筛选所有带有本次特召标识的怪兽，将它们送回持有者卡组。
function c23681456.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c23681456.retfilter,nil,e:GetLabel())
	-- 把目标怪兽以效果原因送回持有者卡组，并使其返回卡组后洗牌（SEQ_DECKSHUFFLE）。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
