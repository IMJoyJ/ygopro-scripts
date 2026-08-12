--スプリガンズ・シップ エクスブロウラー
-- 效果：
-- 8星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：指定对方的怪兽区域或者魔法与陷阱区域1处才能发动。这张卡的超量素材任意数量取除，把指定的区域以及那些前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的那个数量的对方的卡破坏。
-- ②：对方的主要阶段以及战斗阶段才能发动。这张卡直到结束阶段除外。
local s,id,o=GetID()
-- 初始化函数，为卡片注册各项效果（包括XYZ召唤手续、①效果和②效果）
function c62941499.initial_effect(c)
	-- 添加XYZ召唤手续：8星怪兽2只以上（最多99只）
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：指定对方的怪兽区域或者魔法与陷阱区域1处才能发动。这张卡的超量素材任意数量取除，把指定的区域以及那些前面·后面·相邻的区域（怪兽区域·魔法与陷阱区域）存在的那个数量的对方的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62941499,0))  --"指定十字区域破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,62941499)
	e1:SetTarget(c62941499.seqtg)
	e1:SetOperation(c62941499.seqop)
	c:RegisterEffect(e1)
	-- ②：对方的主要阶段以及战斗阶段才能发动。这张卡直到结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62941499,1))  --"这张卡暂时除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_END)
	e2:SetCountLimit(1,62941500)
	e2:SetCondition(c62941499.rmcon)
	e2:SetTarget(c62941499.rmtg)
	e2:SetOperation(c62941499.rmop)
	c:RegisterEffect(e2)
end
-- 过滤场上可破坏的卡（排除场地区和灵摆区，即只选择怪兽区和前5格魔陷区）
function c62941499.desfilter(c)
	return not c:IsLocation(LOCATION_SZONE) or c:GetSequence()<5
end
-- 过滤额外怪兽区域中对应位置的怪兽
function c62941499.exmzfilter(c,seq)
	return c:GetSequence()==seq
end
-- 核心区域判定过滤函数，用于判断卡片是否处于指定的十字区域（指定区域、前后、相邻区域）
function c62941499.seqfilter(c,seq,tp)
	local loc=LOCATION_MZONE
	if seq>=8 then
		loc=LOCATION_SZONE
		seq=seq-8
	end
	if seq>=5 and loc==LOCATION_SZONE then return false end
	if seq==7 and loc==LOCATION_MZONE then return false end
	local cseq=c:GetSequence()
	local cloc=c:GetLocation()
	if cloc==LOCATION_SZONE and cseq>=5 then return false end
	if cloc==LOCATION_MZONE and cseq>=5 and loc==LOCATION_MZONE
		and (seq==1 and cseq==5 or seq==3 and cseq==6 or seq==cseq) then return true end
	if cloc==LOCATION_MZONE and seq>=5 and loc==LOCATION_MZONE
		-- 检查对方的额外怪兽区域是否存在对应位置的怪兽
		and Duel.IsExistingMatchingCard(c62941499.exmzfilter,tp,0,LOCATION_MZONE,1,nil,seq) then
		return seq==5 and cseq==1 or seq==6 and cseq==3
	end
	return cseq==seq or seq<5 and cseq<5 and cloc==loc and math.abs(cseq-seq)==1
end
-- ①效果的发动准备，检查是否能去除素材以及对方场上是否有可破坏的卡
function c62941499.seqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		-- 检查对方场上（怪兽区或前5格魔陷区）是否存在至少1张卡
		and Duel.IsExistingMatchingCard(c62941499.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local filter=0
	for i=0,15 do
		-- 遍历所有区域，若某个区域及其十字范围内没有任何对方的卡，则将该区域标记为不可选
		if not Duel.IsExistingMatchingCard(c62941499.seqfilter,tp,0,LOCATION_ONFIELD,1,nil,i,tp) then
			filter=filter|1<<(i+16)
		end
	end
	-- 提示玩家选择效果的对象区域
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上的一个区域（怪兽区或魔陷区）
	local flag=Duel.SelectField(tp,1,0,LOCATION_ONFIELD,filter)
	-- 在界面上高亮显示玩家选择的区域
	Duel.Hint(HINT_ZONE,tp,flag)
	local seq=math.log(flag>>16,2)
	e:SetLabel(seq)
	-- 获取所选区域及其十字范围内所有对方场上的卡
	local g=Duel.GetMatchingGroup(c62941499.seqfilter,tp,0,LOCATION_ONFIELD,nil,seq,tp)
	-- 设置效果处理信息，表示将破坏上述卡片组中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果的效果处理，去除任意数量的素材并破坏对应数量的十字区域内的卡
function c62941499.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local seq=e:GetLabel()
	-- 计算所选区域及其十字范围内对方卡片的数量
	local ct=Duel.GetMatchingGroupCount(c62941499.seqfilter,tp,0,LOCATION_ONFIELD,nil,seq,tp)
	if ct<=0 or not c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) then return end
	local count=c:RemoveOverlayCard(tp,1,ct,REASON_EFFECT)
	if count<=0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 过滤并让玩家选择与去除素材数量相同的十字区域内的对方卡片
	local g=Duel.SelectMatchingCard(tp,c62941499.seqfilter,tp,0,LOCATION_ONFIELD,count,count,nil,seq,tp)
	-- 闪烁显示被选择要破坏的卡片
	Duel.HintSelection(g)
	-- 破坏选中的卡片
	Duel.Destroy(g,REASON_EFFECT)
end
-- ②效果的发动条件，限制在对方的主要阶段或战斗阶段才能发动
function c62941499.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 判定当前是否为对方的回合
	return Duel.GetTurnPlayer()==1-tp
		and (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
end
-- ②效果的发动准备，检查自身是否能被除外并设置除外操作信息
function c62941499.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置效果处理信息，表示将除外这张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- ②效果的效果处理，将自身暂时除外，并注册在结束阶段返回场上的延迟效果
function c62941499.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于场上，则将其以暂时除外的方式除外，并确认除外成功且卡片未改变
	if c:IsRelateToEffect(e) and Duel.Remove(c,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and c:GetOriginalCode()==id then
		-- 直到结束阶段除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(c)
		e1:SetCountLimit(1)
		e1:SetOperation(c62941499.retop)
		-- 注册该延迟效果到全局环境中
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段将除外的此卡返回场上的效果处理函数
function c62941499.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将暂时除外的此卡返回到场上
	Duel.ReturnToField(e:GetLabelObject())
end
