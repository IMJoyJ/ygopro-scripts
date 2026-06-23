--マドルチェ・ハッピーフェスタ
-- 效果：
-- 从手卡把名字带有「魔偶甜点」的怪兽任意数量特殊召唤。这个效果特殊召唤的怪兽在结束阶段时回到持有者卡组。
function c23681456.initial_effect(c)
	-- 效果发动，设置为自由连锁，可特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23681456.target)
	e1:SetOperation(c23681456.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中名字带有「魔偶甜点」且可特殊召唤的怪兽
function c23681456.filter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，判断是否满足发动条件
function c23681456.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c23681456.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，执行特殊召唤操作
function c23681456.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c23681456.filter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 特殊召唤一张怪兽
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(23681456,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(23681456,0))  --"「魔偶甜点佳节」效果适用中"
			tc=g:GetNext()
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 注册结束阶段时触发的效果，用于将特殊召唤的怪兽送回卡组
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c23681456.retcon)
		e1:SetOperation(c23681456.retop)
		-- 将结束阶段效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 用于判断怪兽是否为本次特殊召唤的怪兽
function c23681456.retfilter(c,fid)
	return c:GetFlagEffectLabel(23681456)==fid
end
-- 结束阶段时的判断条件，确认是否有怪兽需要送回卡组
function c23681456.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c23681456.retfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 将符合条件的怪兽送回卡组
function c23681456.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c23681456.retfilter,nil,e:GetLabel())
	-- 将怪兽送回卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
